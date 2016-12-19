defmodule BPE.QueueManager do
  require Logger
  use GenServer

  def start_link(opts \\ []) do
    name = BPE.Support.Config.queue_manager_server_name(opts[:name])
    {:ok, pid} = GenServer.start_link(__MODULE__, opts, name: :bpe_queue_manager)
    BPE.Support.Logging.start(pid, name)
  end

  def subscribe(pid, queue) do
    GenServer.call(pid, {:subscribe, queue})
  end

  def subscribe(pid, queue, concurrency) do
    GenServer.call(pid, {:subscribe, queue, concurrency})
  end

  def unsubscribe(pid, queue) do
    GenServer.call(pid, {:unsubscribe, queue})
  end

  def handle_call({:subscribe, queue}, from, state) do
    Exq.subscribe(Exq, queue)
    Logger.info "#{__MODULE__} #{inspect(from)} subscribes queue #{queue}"
    {:reply, :ok, state}
  end

  def handle_call({:subscribe, queue, concurrency}, from, state) do
    Exq.subscribe(Exq, queue, concurrency)
    Logger.info "#{__MODULE__} #{inspect(from)} subscribes queue #{queue} with concurrency #{concurrency}"
    {:reply, :ok, state}
  end

  def handle_call({:unsubscribe, queue}, from, state) do
    Exq.unsubscribe(Exq, queue)
    Logger.info "#{__MODULE__} #{inspect(from)} unsubscribes queue #{queue}"
    {:reply, :ok, state}
  end

end
