defmodule BPE.Worker.EmailPersonalizer do
  use Timex
  require Logger

  alias BPE.Worker.RecipientStatusUpdater
  alias BPE.Worker.EmailSender

  def perform(recipient, cfg \\ %{}) do
    recipient = BPE.Recipient.from_params(recipient)
    BPE.Service.Mime.create_eml(recipient) |> eml_handler(recipient, cfg)
  end

  def exq_queue_name, do: "email_personalizer"

  defp get_email_sender_queue(cfg) do
    Map.get(cfg, "email_sender_queue") || EmailSender.exq_queue_name
  end

  defp eml_handler({_, message}, _recipient, _cfg) do
    Logger.error "#{__MODULE__} #{message}"
  end
  defp eml_handler(eml, recipient, cfg) do
    File.mkdir_p("./tmp/data")
    file = "./tmp/data/#{recipient.id}.eml"
    File.write!(file, eml, [:write])

    if recipient.sendat == nil do
      Exq.enqueue(Exq, get_email_sender_queue(cfg), EmailSender, [recipient.id, file])
    else
      send_timestamp = recipient.sendat |> DateFormat.parse!("{ISOz}") |> Date.to_timestamp
      Exq.enqueue_at(Exq, get_email_sender_queue(cfg), send_timestamp, EmailSender, [recipient.id, file])
    end

    attributes = [recipient.id, :personalized, Time.now(:milliseconds), %{eml: eml}]
    Exq.enqueue(Exq, RecipientStatusUpdater.exq_queue_name, RecipientStatusUpdater, attributes)
  end

end
