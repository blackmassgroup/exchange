defmodule VxUnderground.Services.Triage do
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

  @public_url "https://tria.ge/api/v0/"

  plug Tesla.Middleware.BaseUrl, @public_url

  plug Tesla.Middleware.Headers, [
    {"Content-Type", "application/json"},
    {"Authorization", "Bearer #{System.get_env("TRIAGE_API_KEY")}"}
  ]

  plug Tesla.Middleware.JSON

  plug Tesla.Middleware.Retry,
    delay: 5000,
    max_retries: 60,
    max_delay: 300_000,
    should_retry: fn
      {:ok, %{status: status} = resp} when status in [400, 404, 500] ->
        true

      {:ok, _} ->
        false

      {:error, _} ->
        true
    end

  def upload(url) do
    case post("/samples", %{kind: "fetch", url: url}) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        {:ok, body["id"]}

      _ ->
        {:error, :retries_failed}
    end
  end

  def get_sample(id) do
    case get("/samples/" <> id <> "/overview.json") do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        result = Map.take(body["sample"], ["md5", "sha1", "sha256", "sha512", "size", "target"])

        {:ok, result}

      _ ->
        {:error, :retries_failed}
    end
  end
end
