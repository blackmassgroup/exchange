defmodule Exchange.ObanJobs.CloudMigration.SampleRenameScheduler do
  use Oban.Worker, queue: :rename_samples_scheduler, max_attempts: 3, unique: [period: :infinity]

  alias Exchange.Repo.Local, as: Repo
  alias Exchange.Sample
  alias Exchange.ObanJobs.CloudMigration.SampleRename

  import Ecto.Query

  @impl Oban.Worker

  @doc """

  """
  def perform(%Oban.Job{
        args: %{
          "batch_size" => batch_size,
          "offset" => offset,
          "start_date" => start_date,
          "end_date" => end_date
        }
      }) do
    query_start_date = NaiveDateTime.from_iso8601!(start_date)
    query_end_date = NaiveDateTime.from_iso8601!(end_date)

    samples =
      from(s in Sample,
        where: s.inserted_at >= ^query_start_date and s.inserted_at <= ^query_end_date,
        order_by: [asc: s.inserted_at],
        limit: ^batch_size,
        offset: ^offset,
        select: s.sha256
      )
      |> Repo.all()

    Enum.each(samples, fn sha256 ->
      %{sha256: sha256}
      |> SampleRename.new()
      |> Oban.insert()
    end)

    if length(samples) == batch_size do
      %{
        batch_size: batch_size,
        offset: offset + batch_size,
        start_date: start_date,
        end_date: end_date
      }
      |> __MODULE__.new()
      |> Oban.insert()
    end

    :ok
  end
end
