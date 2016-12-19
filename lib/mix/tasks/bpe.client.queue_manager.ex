defmodule Mix.Tasks.Bpe.Client.QueueManager do
  use Mix.Task
  use GenServer

  @shortdoc "BPE queue manager to (un)subscribe exq queues"

  def run(args) do
    {options, _, _} = OptionParser.parse(args,
      strict: [help: :boolean, node: :string, queue: :string, worker: :integer, subscribe: :boolean, unsubscribe: :boolean],
      aliases: [h: :help, n: :node, q: :queue, w: :worker]
    )

    case options do
      [node: node, queue: queue, subscribe: true] -> subscribe(node, queue)
      [node: node, queue: queue, worker: worker, subscribe: true] -> subscribe(node, queue, worker)
      [node: node, queue: queue, unsubscribe: true] -> unsubscribe(node, queue)
      _ -> puts_usage
    end
  end

  defp puts_usage do
    IO.puts """
Usage: mix bpe.client.queue_manager <options>

  Options:
  --help   -h            this help
  --node   -n <String>   node name of the BPE instance
  --queue  -q <String>   exq queue name to (un)subscribe
  --worker -w <Integer>  number of workers for subscription (optional)
  --(un)subscribe        (un)subscribes the queue
"""
  end

  defp subscribe(node, queue) do
    server = connect_server(node)
    case GenServer.call({:bpe_queue_manager, server}, {:subscribe, queue}) do
      :ok -> IO.puts "Subscribed #{queue} on #{server}"
      _   -> IO.puts "Couldn't subscribed #{queue} on #{server}"
    end
  end
  defp subscribe(node, queue, worker) do
    server = connect_server(node)
    case GenServer.call({:bpe_queue_manager, server}, {:subscribe, queue, worker}) do
      :ok -> IO.puts "Subscribed #{queue} on #{server} with #{worker} worker(s)"
      _   -> IO.puts "Couldn't subscribed #{queue} on #{server} with #{worker} worker(s)"
    end
  end

  defp unsubscribe(node, queue) do
    server = connect_server(node)
    case GenServer.call({:bpe_queue_manager, server}, {:unsubscribe, queue}) do
      :ok -> IO.puts "Unsubscribed #{queue} on #{server}"
      _   -> IO.puts "Couldn't unsubscribed #{queue} on #{server}"
    end
  end

  defp connect_server(node) do
    Node.start(:"#{UUID.uuid4()}@localhost")
    server = node |> String.to_atom

    case Node.connect(server) do
      true  ->
        IO.puts "Connected server #{server}"
        server
      false ->
        IO.puts "Couldn't connect server #{server}"
        System.exit(1)
    end
  end

end
