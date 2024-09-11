defmodule Exchange.ObanJobs.Vt.ClearApiLogs do
  use Oban.Worker, queue: :default

  alias Exchange.Repo.Local, as: Repo

  @impl Oban.Worker
  def perform(_job) do
    Repo.query!("TRUNCATE TABLE vt_api_requests")

    :ok
  end
end
