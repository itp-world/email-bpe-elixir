defmodule BPE.Support.Logging do
  require Logger

  def start(pid, module) do
    Logger.info "Start #{inspect(pid)} #{module}"
    {:ok, pid}
  end

end
