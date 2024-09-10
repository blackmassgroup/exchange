defmodule Exchange.Services.MalcoreRuntime do
  @moduledoc """
  Malcore Virus Scanning

  Exchange.Services.MalcoreRuntime("4e21fce851d6a6e26cf8013d43b5024d823b0f3b", 3)
  File upload
  - https://malcore.readme.io/reference/upload
  """
  require Logger
  alias Exchange.Services.S3
  alias Exchange.Samples
  use Tesla

  @public_url "https://api.malcore.io/"

  def upload(malcore_api_key, sample_id) do
    client = build_client(malcore_api_key)

    with sample when sample != nil <- Samples.get_sample(sample_id),
         {:ok, %{body: binary, status_code: 200}} <- S3.get_file_binary(sample.sha256) do
      binary = Base.encode64(binary)

      body = %{filename1: binary, contentType: "", base64: true}

      case Tesla.post(client, "/api/upload", body) do
        {:ok, %Tesla.Env{status: 200, body: body}} ->
          {:ok, body}

        {:error, reason} ->
          Logger.error("Malcore upload failed: #{inspect(reason)}")
          {:error, :failed_to_upload}
      end
    else
      {:error, %Tesla.Env{}} ->
        {:error, :failed_to_upload}

      nil ->
        {:error, :does_not_exist}

      {:ok, %{body: error}} ->
        Logger.error("Malcore error body: #{inspect(error)}")
        {:error, :failed_to_get_binary}
    end
  end

  defp build_client(api_key) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, @public_url},
      {Tesla.Middleware.Headers, build_malcore_headers(api_key)},
      Tesla.Middleware.JSON
    ])
  end

  defp build_malcore_headers(api_key) do
    [
      {"apiKey", api_key},
      {"X-Member", "vxug"},
      {"X-No-Poll", "true"}
    ]
  end
end
