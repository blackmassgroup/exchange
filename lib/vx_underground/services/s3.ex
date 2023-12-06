defmodule VxUnderground.Services.S3 do
  @doc """
  Returns the base URL for the bucket.
  """
  def get_base_url(), do: "http://#{Application.get_env(:ex_aws, :s3)[:host]}/"

  @doc """
  Returns the bucket name from the application config.
  """
  def get_bucket(), do: Application.get_env(:vx_underground, :s3_bucket_name)

  @doc """
  Returns a binary of the file from S3.
  """
  def get_file_binary(object_key) do
    ExAws.S3.get_object(get_bucket(), object_key) |> ExAws.request()
  end

  @doc """
  Returns a presigned URL for the given object key.
  """
  def get_presigned_url(s3_object_key) do
    opts = [expires_in: 300]
    bucket = get_bucket()

    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(:get, bucket, s3_object_key, opts)
    |> case do
      {:ok, url} -> url
      _ -> "#"
    end
  end
end
