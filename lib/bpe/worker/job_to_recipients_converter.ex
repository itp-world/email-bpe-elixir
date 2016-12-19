defmodule BPE.Worker.JobToRecipientsConverter do
  require Logger

  alias BPE.Worker.RecipientCreator

  def perform(file, cfg \\ %{}) do
    if File.exists?(file) do
      read_recipients_from_file(file, cfg)
    else
      Logger.warn("#{__MODULE__} #{file} does not exists!")
    end
  end

  def exq_queue_name, do: "job_to_recipients_converter"

  defp read_recipients_from_file(file, cfg) do
    File.read!(file)
    |> Poison.decode!
    |> Enum.each(fn (data) ->
      Exq.enqueue(Exq, RecipientCreator.exq_queue_name, RecipientCreator, [cfg, data])
    end)

    #TODO should be done when job is definitely finished
    File.rm!(file)
    cfg_file = String.replace(file, ".json", ".cfg")
    if File.exists?(cfg_file) do
      File.rm!(cfg_file)
    end
    File.rm!("#{file}.lock")
  end

end
