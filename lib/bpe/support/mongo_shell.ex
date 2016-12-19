defmodule BPE.Support.MongoShell do

  def execute(cmd) do
    System.cmd("mongo", create_args(cmd))
  end

  def create_args(cmd) do
    mongodb = BPE.Support.Config.get(:mongodb)
    args = [mongodb[:database], "--eval", cmd]

    if mongodb[:hostname] != nil, do:
      args = args |> List.insert_at(-3, ["--host", mongodb[:hostname]])
    if mongodb[:port] != nil, do:
      args = args |> List.insert_at(-3, ["--port", mongodb[:port]])
    if mongodb[:username] != nil, do:
      args = args |> List.insert_at(-3, ["--username", mongodb[:username]])
    if mongodb[:password] != nil, do:
      args = args |> List.insert_at(-3, ["--password", mongodb[:password]])

    args |> List.flatten
  end

end
