defmodule VExchange.Services.VirusTotal do
  @moduledoc """
  Module for interacting with the Virus Total API.

  https://developers.virustotal.com/reference/authentication
  https://docs.virustotal.com/reference/files
  https://docs.virustotal.com/reference/analyses-object
  https://docs.virustotal.com/reference/files-scan

  This module supports:
  - Retrieving samples
  - Submitting files for processing
  - Posting comments to resources
  """
  use Tesla
  alias Tesla.Multipart
  require Logger

  @public_url "https://www.virustotal.com/api/v3"

  plug Tesla.Middleware.BaseUrl, @public_url
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Logger
  plug VExchange.VtApiRequestLogger

  plug Tesla.Middleware.Headers, [
    {"accept", "application/json"},
    {"x-apikey", "#{System.get_env("VIRUS_TOTAL_API_KEY")}"}
  ]

  @doc """
  Gets a VirusTotal sample by SHA256.

    ## Example
        iex> VExchange.Services.VirusTotal.get_sample("1234567890")
        {:ok, %{}}
  """
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

  @doc """
  Submits a file for processing to VirusTotal
  """
  def submit_for_processing(file) do
    mp =
      Multipart.new()
      |> Multipart.add_file_content(file, "file", name: "file", filename: "file")

    case post("/files", mp, headers: [{"content-type", "multipart/form-data"}]) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        {:ok, body["data"]}

      _ ->
        {:error, :failed_to_post_to_vt}
    end
  end

  @doc """
  Posts a comment to a VirusTotal resource identified by its URL.

  ## Parameters
    - `resource_url`: The URL of the resource to comment on.
    - `comment`: The comment to be posted.

  ## Example
      iex> VExchange.Services.VirusTotal.post_comment("https://www.virustotal.com/gui/file/.../detection", "This file seems suspicious")
      {:ok, %{"data" => ...}}
  """
  def post_file_comment(file_hash, comment) do
    url = "/files/#{file_hash}/comments"

    body = %{
      "data" => %{
        "type" => "comment",
        "attributes" => %{
          "text" => comment
        }
      }
    }

    case post(url, body, headers: [{"content-type", "application/json"}]) do
      {:ok, %Tesla.Env{body: body, status: status}} when status in [200, 409] ->
        {:ok, body["data"]}

      {:ok, %Tesla.Env{status: status}} ->
        {:error, "Failed with status: #{status}"}

      {:error, reason} ->
        Logger.error("Failed to post to VirusTotal: #{inspect(reason)}")
        {:error, "Failed with reason: #{inspect(reason)}"}
    end
  end

  @doc """
  Gets a VirusTotal analysis by ID.

  Example:
  ```
  {:ok, analysis} = VExchange.Services.VirusTotal.get_analysis("1234567890")
  ```
  """
  def get_analysis(nil), do: {:error, :invalid_analysis_id}

  def get_analysis(analysis_id) do
    case get("/analyses/#{analysis_id}") do
      {:ok, %Tesla.Env{body: %{"data" => data}, status: 200}} ->
        {:ok, data}

      {:ok, %Tesla.Env{status: 404}} ->
        {:error, :analysis_not_found}

      {:ok, %Tesla.Env{status: status}} ->
        {:error, "Failed with status: #{status}"}

      {:error, _reason} ->
        {:error, :request_failed}
    end
  end

  @doc """
  Returns true if the sample is considered malware.

  It's malware if:
  1. "popular_threat_classification" exists, or
  2. Kaspersky's analysis result is present and not "clean" or nil.

  https://docs.virustotal.com/reference/files
  """
  def is_malware?(attrs) do
    has_popular_threat = Map.has_key?(attrs, "popular_threat_classification")

    kaspersky_result =
      get_in(attrs, ["last_analysis_results", "Kaspersky", "result"])

    kaspersky_says_so = kaspersky_result not in [nil, "clean"]

    has_popular_threat or kaspersky_says_so
  end
end
