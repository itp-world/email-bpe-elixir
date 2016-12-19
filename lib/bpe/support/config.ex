defmodule BPE.Support.Config do
  @default_config %{
    name: BPE,
    mode: :default,
    node: "bpe@127.0.0.1",
    mongodb: [database: "bpe"],
    template_engine: [url: nil, from: "email-bpe@localhost"]
  }

  @doc """
   Returns BPE's node name (default is :bpe@localhost)
  """
  def node_name(name) do
    unless name, do: name = get(:node)
    name |> String.to_atom
  end

  @doc """
   Returns top supervisor's name (default is BPE.Supervisor)
  """
  def top_supervisor(name) do
    unless name, do: name = get(:name)
    "#{name}.Supervisor" |> String.to_atom
  end

  @doc """
   Returns queue manager's name (default is BPE.QueueManager)
  """
  def queue_manager_server_name(name) do
    unless name, do: name = get(:name)
    "#{name}.QueueManager" |> String.to_atom
  end

  @doc """
   Returns exq's configured queue names
  """
  def exq_queue_names() do
    get(:exq, :queues, [])
    |> Enum.map(fn queue_config ->
      case queue_config do
        {queue, _concurrency} -> queue
        queue -> queue
      end
    end)
  end

  def get(key) do
    get(key, Map.get(@default_config, key))
  end

  def get(key, fallback) do
    get(:bpe, key, fallback)
  end

  def get(app, key, fallback) do
    Application.get_env(app, key, fallback)
  end
end
