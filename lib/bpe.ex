defmodule BPE do
  require Logger
  use Application

  alias BPE.Support.Config
  alias BPE.Support.Logging

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    start_link
  end

  def start_link(opts \\ []) do
    # Guarantee for an index on the job_id and email fields in recipients collection
    BPE.Support.MongoShell.execute("db.recipients.createIndex({job_id: 1, email: 1}, {unique: true})")

    name = Config.top_supervisor(opts[:name])
    {:ok, pid} = get_children |> Supervisor.start_link(strategy: :one_for_one, name: name)
    Logging.start(pid, name)

    start_node(Config.node_name(opts[:node]))

    {:ok, pid}
  end

  def stop(nil), do: :ok
  def stop(pid) when is_pid(pid), do: Process.exit(pid, :shutdown)
  def stop(name) do
      name
      |> Config.top_supervisor
      |> Process.whereis
      |> stop
  end

  defp get_children do
    import Supervisor.Spec, warn: false
    [
      supervisor(Mongo.IdServer, []),
      supervisor(BPE.MongodbPool, []),
      worker(BPE.QueueManager, [])
    ]
  end

  defp start_node(name) do
    case Node.start(name) do
      {:ok, pid} -> Logging.start(pid, "BPE Node #{name}")
      _ -> Logger.warn "The BPE Node couldn't be started! Is epmd running?"
    end
  end

end
