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

  # maybe this was missing
  plug Tesla.Middleware.JSON

  # @post_headers [
  #   {"accept", "application/json"},
  #   {"content-type", "multipart/form-data"},
  #   {"x-apikey", "#{@api_key}"}
  # ]

  # def submit_for_processing(file) do
  #   _http_client(@post_headers)
  #   |> Tesla.post(@public_url <> "/files", %{file: file})
  # end

  def get_sample(nil), do: nil

  def get_sample(sha_256) do
    url = "/files/" <> sha_256

    # _http_client(@get_headers)
    # |> Tesla.get(url)

    case get(url) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        {:ok, body["data"]}

      _ ->
        {:error, :retries_failed}
    end
  end

  # @doc """
  # Setup the Telsa HTTP Client and return it
  # """
  # def _http_client(headers) do
  #   middlewares = [{Tesla.Middleware.Headers, headers}]

  #   Tesla.client([{Tesla.Middleware.Headers, headers}], Tesla.Adapter.Hackney)
  # end
end
