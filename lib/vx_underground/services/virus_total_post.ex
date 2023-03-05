defmodule VxUnderground.Services.VirusTotalPost do
  @moduledoc """
  Module for interacting with the Virus Total API

  https://developers.virustotal.com/reference/authentication

  --- WIP ---
  """
  alias Tesla.Multipart
  use Tesla

  @public_url "https://www.virustotal.com/api/v3"

  plug Tesla.Middleware.BaseUrl, @public_url

  plug Tesla.Middleware.Headers, [
    {"accept", "application/json"},
    {"content-type", "multipart/form-data"},
    {"x-apikey", "#{System.get_env("VIRUS_TOTAL_API_KEY")}"}
  ]

  plug Tesla.Middleware.JSON

  def submit_for_processing(file) do
    mp =
      Multipart.new()
      |> Multipart.add_file(file, name: "file", filename: "file")

    case post(@public_url <> "/files", mp) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        {:ok, body["data"]}

      _ ->
        {:error, :retries_failed}
    end
  end
end
