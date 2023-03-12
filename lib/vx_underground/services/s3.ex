defmodule VxUnderground.Services.S3 do
  @bucket "testing-herbs"
  @region "us-east-1"
  @provider "wasabisys"

  @base_url "http://#{@bucket}.s3.#{@region}.#{@provider}.com/"

  def get_base_url(), do: @base_url

  def get_bucket(), do: @bucket
end
