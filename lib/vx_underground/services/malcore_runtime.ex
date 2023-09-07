defmodule VxUnderground.Services.MalcoreRuntime do
  @moduledoc """
  Malcore Virus Scanning

  File upload
  - https://malcore.readme.io/reference/upload
  """
  alias VxUnderground.Services.S3
  alias VxUnderground.Samples
  use Tesla

  @public_url "https://api.malcore.io/"

  plug Tesla.Middleware.BaseUrl, @public_url
  plug Tesla.Middleware.JSON

  def upload(malcore_api_key, sample_id) do
    client = build_client(malcore_api_key)

    with sample when sample != nil <- Samples.get_sample(sample_id),
         {:ok, %{body: binary, status_code: 200}} <- S3.get_file_binary(sample.s3_object_key),
         {:ok, %Tesla.Env{body: body, status: 200}} <-
           client |> post("/api/upload", %{}, query: [{sample.s3_object_key, binary}]) do
      {:ok, body}
    else
      {:error, %Tesla.Env{}} ->
        {:error, :failed_to_upload}

      nil ->
        {:error, :does_not_exist}

      _ ->
        {:error, :failed_to_get_binary}
    end
  end

  defp build_client(malcore_api_key) do
    Tesla.client([
      {Tesla.Middleware.Headers, build_malcore_headers(malcore_api_key)},
      {Tesla.Middleware.BaseUrl, @public_url},
      Tesla.Middleware.JSON
    ])
  end

  def build_malcore_headers(api_key) do
    [
      {"Content-Type", "application/json"},
      {"apiKey", api_key},
      {"X-Member", "vxug"}
    ]
  end
end
