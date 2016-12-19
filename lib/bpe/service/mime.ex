defmodule BPE.Service.Mime do
  require Logger
  use Timex

  def create_eml(recipient) do
    config = BPE.Support.Config.get(:template_engine, [])
    if config[:url] != nil do
      %Mailman.Email{
        from:        config[:from],
        to:          ["#{recipient.name} <#{recipient.email}>"],
        subject:     "Test template email",
        html:        personalized_template(recipient, "#{config[:url]}test"),
        attachments: prepare_attachments(recipient.template_data["attachments"])
      } |> Mailman.Render.render(%Mailman.EexComposeConfig{})
    else
      {:error, "DUH! Undefined email template service!"}
    end
  end

  def send_eml(recipient_id, eml) do
    date = DateTime.now |> Timex.format!("%Y%m%d%H%M", :strftime)
    File.mkdir_p("./tmp/smtp/#{date}")
    eml |> File.rename("./tmp/smtp/#{date}/#{recipient_id}.eml")
  end

  defp personalized_template(recipient, template_engine_url) do
    HTTPotion.post(template_engine_url, [
      body:    %{data: recipient} |> Poison.encode!,
      headers: ["Content-Type": "application/json"]
    ]).body
  end

  defp prepare_attachments(attachments) do
    attachments |> Enum.map(fn(file) -> Mailman.Attachment.inline!(file) end)
  end

end
