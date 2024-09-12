defmodule Exchange.Services.S3 do
  alias ExAws.S3
  require Logger

  @doc """
  Returns the base URL for the bucket.
  """
  def get_base_url(), do: "http://#{Application.get_env(:exchange, :s3_host)}/"

  @doc """
  Returns the bucket name from the application config.
  """
  def get_wasabi_bucket(), do: Application.get_env(:exchange, :s3_bucket_name)

  @doc """
  Returns the bucket name from the application config.
  """
  def get_private_wasabi_bucket(), do: Application.get_env(:exchange, :vxu_bucket_name)

  @doc """
  Returns a binary of the file from S3.
  """
  def get_file_binary(object_key) do
    S3.get_object(get_wasabi_bucket(), object_key) |> ExAws.request(wasabi_config())
  end

  @doc """
  Returns a presigned URL for the given object key.
  """
  def get_presigned_url(s3_object_key) do
    opts = [expires_in: 300]
    bucket = get_wasabi_bucket()
    config_opts = wasabi_config()

    ExAws.Config.new(:s3, config_opts)
    |> S3.presigned_url(:get, bucket, s3_object_key, opts)
    |> case do
      {:ok, url} -> url
      _ -> "#"
    end
  end

  @doc """
  Config Used to Upload to Wasabi
  """
  def wasabi_config() do
    host = Application.get_env(:exchange, :s3_host)
    secret_access_key = Application.get_env(:exchange, :s3_secret_access_key)
    access_key_id = Application.get_env(:exchange, :s3_access_key_id)

    [host: host, secret_access_key: secret_access_key, access_key_id: access_key_id]
  end

  @doc """
  Upload an object to s3
  """
  def put_object(object_key, binary, :wasabi) do
    opts = [{:content_type, "application/octet-stream"}]
    config_opts = wasabi_config()

    get_wasabi_bucket()
    |> S3.put_object(object_key, binary, opts)
    |> ExAws.request(config_opts)
  end

  def put_object(object_key, binary, :wasabi_private) do
    opts = [{:content_type, "application/octet-stream"}]
    config_opts = wasabi_config()

    get_private_wasabi_bucket()
    |> S3.put_object(object_key, binary, opts)
    |> ExAws.request(config_opts)
  end

  @doc """
  Copies a file from the mwdb bucket to the private vxug for processing.
  """
  def copy_file_to_daily_backups(_src_object, false = _is_new_upload), do: {:ok, :old_sample}

  def copy_file_to_daily_backups(src_object, _is_new_upload) do
    dest_bucket = get_private_wasabi_bucket()
    src_bucket = get_wasabi_bucket()
    date = Date.utc_today() |> Date.to_iso8601()
    dest_object = "/Daily/#{date}/#{src_object}"
    config_opts = wasabi_config()

    S3.put_object_copy(dest_bucket, dest_object, src_bucket, src_object)
    |> ExAws.request(config_opts)
  end

  @doc """
  Files uploaded through the admin UI are uploaded direct to s3 and have to be properly renamed.
  """
  def rename_uploaded_file(sha256, name) do
    bucket = get_wasabi_bucket()
    opts = wasabi_config()

    with(
      {:ok, _body} <- S3.put_object_copy(bucket, sha256, bucket, name) |> ExAws.request(opts),
      {:ok, _body} <- S3.delete_object(bucket, name) |> ExAws.request(opts)
    ) do
      {:ok, sha256}
    else
      _ ->
        {:error, :s3_file_rename_failure}
    end
  end

  @doc """
  Deletes an object from the exchange bucket.
  """
  def delete_exchange_object(sha256) do
    bucket = get_wasabi_bucket()
    opts = wasabi_config()

    with(
      {:ok, %{status_code: 204}} <-
        S3.delete_object(bucket, sha256) |> ExAws.request(opts)
    ) do
      {:ok, sha256}
    else
      error ->
        Logger.error("Error deleting object from S3: #{inspect(error)}")
        {:error, :delete_exchange_object_failure}
    end
  end
end
