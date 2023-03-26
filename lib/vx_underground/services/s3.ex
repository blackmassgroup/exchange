defmodule VxUnderground.Services.S3 do
  @region "us-east-1"
  @provider "wasabisys"

  def get_base_url(), do: "http://#{get_bucket()}.s3.#{@region}.#{@provider}.com/"

  def get_bucket(), do: Application.get_env(:vx_underground, :s3_bucket_name)
end
