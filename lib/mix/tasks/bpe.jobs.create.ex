defmodule Mix.Tasks.Bpe.Jobs.Create do
  use Mix.Task
  use Timex

  @shortdoc "Creates jobs for the BPE job poller worker"

  def run(args) do
    {options, _, _} = OptionParser.parse(args,
      strict: [help: :boolean, jobs: :integer, recipients: :integer, attachment: :string, sendat: :string, nosendtime: :string],
      aliases: [h: :help, j: :jobs, r: :recipients, a: :attachment]
    )

    case options do
      [jobs: _, recipients: _, attachment: _, sendat: sendat, nosendtime: nosendtime] ->
        case sendat |> DateFormat.parse("{ISOz}") do
          {:ok, _} ->
            case nosendtime |> parse_nosendtime do
              {:ok, _} -> process(options)
              {:error, _} -> puts_usage
            end
          {:error, _} -> puts_usage
        end
      [jobs: _, recipients: _, attachment: _, nosendtime: nosendtime] ->
        case nosendtime |> parse_nosendtime do
          {:ok, _} -> process(options)
          {:error, _} -> puts_usage
        end
      [jobs: _, recipients: _, attachment: _, sendat: sendat] ->
         case sendat |> DateFormat.parse("{ISOz}") do
           {:ok, _} -> process(options)
           {:error, _} -> puts_usage
         end
      [jobs: _, recipients: _, attachment: _] -> process(options)
      _ -> puts_usage
    end
  end

  defp puts_usage do
    IO.puts """
Usage: mix bpe.jobs.create <options>

  Options:
  --help       -h             this help
  --jobs       -j <Integer>   number of jobs
  --recipients -r <Integer>   number of recipients per job
  --attachment -a <String>    attachment file path, use "" for no attachments
  --sendat        <DateTime>  UTC date emails are sent to recipients, optional
                              e.g. 2016-02-05T14:59:38Z (ISO 8601)
  --nosendtime    <String>    optional UTC time interval during which no emails
                              are allowed to be sent, format "HH:MM HH:MM"
"""
  end

  defp parse_nosendtime(nosendtime) do
    case String.split(nosendtime) do
      [startat, endat] ->
        case parse_time(startat) do
          {:ok, s} ->
            case parse_time(endat) do
              {:ok, e} ->
                {:ok, %{nosendtime: %{startat: s, endat: e}}}
              _ -> {:error, {}}
            end
          _ -> {:error, {}}
        end
      _ -> {:error, {}}
    end
  end

  defp parse_time(time) do
    case String.split(time, ":")
      |> Enum.map(fn (s) -> {i,_} = Integer.parse(s); i end) do
      [h, m] when h >= 0 and h <= 23
              and m >= 0 and m <= 59 ->
        {:ok, %{hour: h, minute: m}}
      _ -> {:error, {}}
    end
  end

  defp process(options) do
    File.mkdir_p("./tmp/jobs")
    me = self

    1..options[:jobs]
    |> Enum.map(fn (i) ->
      spawn_link(fn -> send me, create_job(i, options) end)
    end)
    |> Enum.each(fn (_) ->
      receive do result -> IO.puts result end
    end)
  end

  defp create_job(jid, options) do
    attachment = options[:attachment] |> String.split
    Enum.map(1..options[:recipients], fn (i) ->
      key = "#{jid}-#{i}"
      case options do
        [jobs: _, recipients: _, sendat: sendat] ->
          Map.put(base_recipient_data(key, attachment), :sendat, sendat)
        _ ->
          base_recipient_data(key, attachment)
      end
    end)
    |> Poison.encode!
    |> write_job
    |> write_job_config(options)
  end

  defp base_recipient_data(key, attachment) do
    %{
      name: "Test #{key}",
      email: "test#{key}@example.org",
      template_data: %{
        attachments: attachment,
        table: %{
          cols: ["Name", "Value"],
          rows: [
            %{"Name": "Name #1", "Value": "Value #1"},
            %{"Name": "Name #2", "Value": "Value #2"},
            %{"Name": "Name #3", "Value": "Value #3"},
            %{"Name": "Name #4", "Value": "Value #4"},
            %{"Name": "Name #5", "Value": "Value #5"},
            %{"Name": "Name #6", "Value": "Value #6"},
            %{"Name": "Name #7", "Value": "Value #7"},
            %{"Name": "Name #8", "Value": "Value #8"},
            %{"Name": "Name #9", "Value": "Value #9"}
          ]
        }
      }
    }
  end

  defp write_job(json) do
    file = "./tmp/jobs/#{UUID.uuid4()}.json"
    File.write!(file, json, [:write])
    file
  end

  defp write_job_config(file, options) do
    case options do
      [jobs: _, recipients: _, sendat: _, nosendtime: nosendtime] ->
        write_job_config_inner(file, nosendtime)
      [jobs: _, recipients: _, nosendtime: nosendtime] ->
        write_job_config_inner(file, nosendtime)
      _ -> file
    end
  end

  defp write_job_config_inner(file, nosendtime) do
    case nosendtime |> parse_nosendtime do
      {:ok, job_config} ->
        file
        |> String.replace(".json",".cfg")
        |> File.write!( job_config |> Poison.encode! , [:write])
      {:error, _} -> IO.puts "Error parsing nosendtime, no job config file written!"
    end
  end

end
