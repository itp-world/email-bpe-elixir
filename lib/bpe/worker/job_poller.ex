defmodule BPE.Worker.JobPoller do
  alias BPE.Worker.JobConfigurator

  def perform do
    jobs = BPE.Service.Store.get_new_jobs

    Enum.each(jobs, fn(job) ->
      if !File.exists?("#{job}.lock") do
        File.touch!("#{job}.lock")
        Exq.enqueue(Exq, JobConfigurator.exq_queue_name, JobConfigurator, [job])
      end
    end)
  end

  def exq_queue_name, do: "job_poller"

end
