defmodule BPE.Worker.RecipientCreator do
  use Timex

  alias BPE.Worker.EmailPersonalizer

  def perform(job_cfg, data) do
      data = BPE.Recipient.create(recipient_data_map(job_cfg["job_id"], data))
      |> Map.put(:sendat, data["sendat"])
      |> Map.put(:template_data,  data["template_data"])

      Exq.enqueue(Exq, EmailPersonalizer.exq_queue_name, EmailPersonalizer, [ data, job_cfg ])
  end

  def exq_queue_name, do: "recipient_creator"

  defp recipient_data_map(job_id, data) do
    recipient =  %{
      job_id: job_id,
      name: data["name"],
      email: data["email"],
      statuses: %{created: %BSON.DateTime{utc: Time.now(:milliseconds)}},
    }

    if data["sendat"] != nil do
      t = data["sendat"] |> DateFormat.parse!("{ISOz}")
      sendtime_to_store = BSON.DateTime.from_datetime({
          { t.year, t.month, t.day },
          { t.hour, t.minute, t.second, t.ms }})
      recipient = Map.put(recipient, :sendat, sendtime_to_store)
    end

    recipient
  end

end
