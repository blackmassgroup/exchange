defmodule VExchange.Services.TriageSearch do
  @moduledoc """
  Triage Virus Scanning

  Authentication
  - https://tria.ge/docs/faq/
  - https://tria.ge/docs/cloud-api/conventions/#authentication

  Submission
  - https://tria.ge/docs/cloud-api/submit/
  - https://tria.ge/docs/cloud-api/samples/#post-samples

  URLS
  - https://tria.ge/api/v0/
  - https://sandbox.recordedfuture.com/api/v0/
  - https://private.tria.ge/api/v0/
  """
  use Tesla
  require Logger

  @public_url "https://tria.ge/api/v0/"

  plug Tesla.Middleware.BaseUrl, @public_url

  plug Tesla.Middleware.Headers, [
    {"Content-Type", "application/json"},
    {"Authorization", "Bearer #{System.get_env("TRIAGE_API_KEY")}"}
  ]

  plug Tesla.Middleware.JSON

  def search(nil), do: {:error, :nil_sent}

  def search(sha256) do
    case get("/search?query=sha256:" <> sha256) do
      {:ok, result} ->
        {:ok, result.body}

      {:error, :econnrefused} ->
        {:error, :econnrefused}

      {:error, msg} ->
        Logger.error(msg)

        {:error, msg}
    end
  end
end
