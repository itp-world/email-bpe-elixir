defmodule BPE.Support.RedisCLI do
  alias BPE.Support.Config

  def execute(cmd) do
    System.cmd("redis-cli", create_args(cmd))
  end

  def create_args(cmd) do
    args = ["-n", "#{Config.get(:exq, :database, 0)}", cmd]
    host = Config.get(:exq, :host, nil)
    port = Config.get(:exq, :port, nil)
    password = Config.get(:exq, :password, nil)

    if host != nil, do:
      args = args |> List.insert_at(-4, ["-h", host])
    if port != nil, do:
      args = args |> List.insert_at(-4, ["-p", "#{port}"])
    if password != nil, do:
      args = args |> List.insert_at(-4, ["-a", password])

    args |> List.flatten
  end

end
