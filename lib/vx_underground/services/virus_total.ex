defmodule VxUnderground.Services.VirusTotal do
  @moduledoc """
  Module for interacting with the Virus Total API

  https://developers.virustotal.com/reference/authentication

  --- WIP ---
  """
  @api_key System.get_env("VIRUS_TOTAL_API_KEY")

  @public_url "https://www.virustotal.com/api/v3"

  @get_headers [
    {"Content-Type", "application/json"},
    {"x-apikey", "#{@api_key}"}
  ]

  @post_headers [
    {"accept", "application/json"},
    {"content-type", "multipart/form-data"},
    {"x-apikey", "#{@api_key}"}
  ]

  def submit_for_processing(file) do
    _http_client(@post_headers)
    |> Tesla.post(@public_url <> "/files", %{file: file})
  end

  def get_sample(sha_256) do
    _http_client(@get_headers)
    |> Tesla.get("/files/" <> sha_256)
  end

  @doc """
  Setup the Telsa HTTP Client and return it
  """
  def _http_client(headers) do
    middlewares = [
      {Tesla.Middleware.Headers, headers}
    ]

    Tesla.client(middlewares, {Tesla.Adapter.Mint, timeout: 240_000})
  end
end
