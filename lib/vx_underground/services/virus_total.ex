defmodule VxUnderground.Services.VirusTotal do
  @moduledoc """
  Module for interacting with the Virus Total API

  https://developers.virustotal.com/reference/authentication

  --- WIP ---
  """
  use Tesla

  @public_url "https://www.virustotal.com/api/v3"

  plug Tesla.Middleware.BaseUrl, @public_url

  plug Tesla.Middleware.Headers, [
    {"Content-Type", "application/json"},
    {"x-apikey", "#{System.get_env("VIRUS_TOTAL_API_KEY")}"}
  ]

  plug Tesla.Middleware.JSON
  def get_sample(nil), do: {:error, :nil_sent}

  def get_sample(sha_256) do
    url = "/files/" <> sha_256

    case get(url) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        {:ok, body["data"]}

      _ ->
        {:error, :does_not_exist}
    end
  end
end
