defmodule Exchange.Repo.Migrations.CreateVtApiRequests do
  use Ecto.Migration

  def change do
    create table(:vt_api_requests) do
      add :raw_request, :text
      add :raw_response, :text
      add :http_response_code, :integer
      add :url, :string

      timestamps()
    end
  end
end
