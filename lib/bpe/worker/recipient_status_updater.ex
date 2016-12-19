defmodule BPE.Worker.RecipientStatusUpdater do

  def perform(recipient_id, status, time, attributes \\ %{}) do
    attrs = Map.put(attributes, "statuses.#{status}", %BSON.DateTime{utc: time})
    BPE.Recipient.update(recipient_id, attrs)
  end

  def exq_queue_name, do: "recipient_status_updater"

end
