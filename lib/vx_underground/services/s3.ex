defmodule VxUnderground.Services.S3 do
  @bucket "vxug"
  @region "eu-central-1"
  @provider "wasabisys"

  @base_url "http://#{@bucket}.s3.#{@region}.#{@provider}.com/"

  def get_base_url(), do: @base_url
end
