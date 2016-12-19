defmodule BPE.Worker.JobConfigurator do
  require Logger

  alias BPE.Worker.JobToRecipientsConverter

  def perform(job_file_path) do
    job_id = job_file_path |> Path.basename |> Path.rootname
    job_config = %{job_id: job_id}

    cfg_file = String.replace(job_file_path, ".json", ".cfg")
    if File.exists?(cfg_file) do
      # read queue schedule config
      queue_schedule_cfg = File.read!(cfg_file) |> Poison.decode!

      # individual email sender queue
      job_config = Map.put(job_config, :email_sender_queue, "email_sender_#{job_id}")

      # TODO Do we really want to have the default number of workers?
      # TODO Delete of Quantum crons when email sending jobs are finished
      nosendtime = queue_schedule_cfg["nosendtime"]
      Quantum.add_job(
        get_cron_schedule(nosendtime, "startat"),
        fn -> unsubscribe_queue(job_config.email_sender_queue) end
      )
      Quantum.add_job(
        get_cron_schedule(nosendtime, "endat"),
        fn -> subscribe_queue(job_config.email_sender_queue) end
      )

      # TODO Do we really want to have the default number of workers?
      Exq.subscribe(Exq, job_config.email_sender_queue)
    end

    Exq.enqueue(Exq, JobToRecipientsConverter.exq_queue_name, JobToRecipientsConverter, [job_file_path, job_config])
  end

  def subscribe_queue(queue) do
    Logger.info "Subscribed queue #{queue}"
    Exq.subscribe(Exq, queue)
  end

  def unsubscribe_queue(queue) do
    Logger.info "Unsubscribed queue #{queue}"
    Exq.unsubscribe(Exq, queue)
  end

  defp get_cron_schedule(nosendtime, time) do
    "#{nosendtime[time]["minute"]} #{nosendtime[time]["hour"]} * * *"
  end

  def exq_queue_name, do: "job_configurator"

end
