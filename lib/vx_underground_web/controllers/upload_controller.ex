defmodule VxUndergroundWeb.UploadController do
  use VxUndergroundWeb, :controller

  action_fallback VxUndergroundWeb.FallbackController

  plug VxUndergroundWeb.Plugs.ApiKeyValidator

  alias VxUnderground.Services.S3
  alias VxUnderground.Samples
  #   alias VxUnderground.Services.MalcoreRuntime

  def create(conn, %{"file" => file} = _params) when is_binary(file) do
    # malcore_api_key = conn.assigns.current_user.malcore_api_key

    #  {:ok, _user} <-
    #    malcore_api_key |> build_malcore_headers() |> MalcoreRuntime.upload(sample.id)
    with params <- build_sample_params(file),
         {:ok, sample} <- Samples.create_sample(params),
         {:ok, sample} <- upload_file(sample.s3_object_key, file) do
      conn
      |> put_status(:created)
      |> render(:show, sample: sample)
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> put_view(html: VxUndergroundWeb.ErrorHTML, json: VxUndergroundWeb.ErrorJSON)
    |> render(:"400")
  end

  def build_malcore_headers(api_key) do
    [
      {"Content-Type", "application/json"},
      {"apiKey", api_key},
      {"X-Member", "vxug"}
    ]
  end

  def upload_file(object_key, file) do
    S3.get_bucket()
    |> ExAws.S3.put_object(object_key, file)
    |> ExAws.request()
  end

  def build_sample_params(file) do
    type = "unknown"

    md5 =
      :crypto.hash(:md5, file)
      |> Base.encode16()
      |> String.downcase()

    sha1 =
      :crypto.hash(:sha, file)
      |> Base.encode16()
      |> String.downcase()

    sha256 =
      :crypto.hash(:sha256, file)
      |> Base.encode16()
      |> String.downcase()

    sha512 =
      :crypto.hash(:sha3_512, file)
      |> Base.encode16()
      |> String.downcase()

    %{
      md5: md5,
      sha1: sha1,
      sha256: sha256,
      sha512: sha512,
      type: type,
      size: byte_size(file),
      names: [sha256],
      s3_object_key: sha256,
      first_seen: DateTime.utc_now() |> DateTime.truncate(:second)
    }
  end
end
