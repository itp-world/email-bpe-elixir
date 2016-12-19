defmodule Mix.Tasks.Bpe.Reset do
  use Mix.Task

  @shortdoc "Resets the BPE application (Redis / MobgoDB / tmp directory)"

  def run(_args) do
    BPE.Support.RedisCLI.execute("FLUSHDB")
    BPE.Support.MongoShell.execute("db.dropDatabase()")
    File.rm_rf!("./tmp")
    File.mkdir!("./tmp")
  end

end
