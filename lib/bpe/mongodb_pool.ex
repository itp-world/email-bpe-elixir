defmodule BPE.MongodbPool do
  use Mongo.Pool, name: __MODULE__, adapter: Mongo.Pool.Poolboy

  alias BPE.Worker.RecipientCreator
  alias BPE.Worker.RecipientStatusUpdater

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    start_link
  end

  def start_link do
    BPE.Support.Config.get(:mongodb, [])
    |> Keyword.put_new_lazy(:pool_size, fn -> worker_depending_pool_size end)
    |> BPE.MongodbPool.start_link
  end

  defp worker_depending_pool_size do
    BPE.Support.Config.get(:exq, :queues, [])
    |> Enum.filter_map(
      fn({q, _w}) -> q == RecipientCreator.exq_queue_name || q == RecipientStatusUpdater.exq_queue_name end,
      fn({_q, w}) -> w end)
    |> Enum.reduce(0, fn(x, acc) -> x+acc end)
  end

end
