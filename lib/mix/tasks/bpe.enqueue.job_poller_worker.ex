defmodule Mix.Tasks.Bpe.Enqueue.JobPollerWorker do
  use Mix.Task

  @shortdoc "Enqueues the BPE job poller worker"

  def run(_args) do
    Exq.start_link
    Exq.enqueue(Exq, BPE.Worker.JobPoller.exq_queue_name, BPE.Worker.JobPoller, [])
  end
end
