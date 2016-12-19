defmodule BPE.Worker.EmailSender do
  use Timex

  alias BPE.Worker.RecipientStatusUpdater

  def perform(recipient_id, eml) do
    BPE.Service.Mime.send_eml(recipient_id, eml)

    attributes = [recipient_id, :sended, Time.now(:milliseconds)]
    Exq.enqueue(Exq, RecipientStatusUpdater.exq_queue_name, RecipientStatusUpdater, attributes)
  end

  def exq_queue_name, do: "email_sender"

end
