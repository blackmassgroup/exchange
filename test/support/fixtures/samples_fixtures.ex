defmodule VxUnderground.SamplesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VxUnderground.Samples` context.
  """

  @doc """
  Generate a sample.
  """
  def sample_fixture(attrs \\ %{}) do
    {:ok, sample} =
      attrs
      |> Enum.into(%{
        names: ["Test Name"],
        first_seen: ~U[2023-02-05 17:21:00Z],
        hash: "some new hash",
        s3_object_key: "some new s3_object_key",
        size: 43,
        tags: [%VxUnderground.Tags.Tag{name: "Test"}],
        type: "some new type",
        md5: "8f1e3ebe78bf1e81b9d278dfdf278f26",
        sha1: "261ce8aa87bd3c520c577290ce3073d83509e349",
        sha256: "adf8e94bced4691aadc5b7695116929289623cd925bbf087165c6a7e6e3dd6eb",
        sha512:
          "38ae7e95990689ff4f209f765452a164ef22ce5fd805ebc185278b8aa03196b3f7e76df17da6d755d3e4cd58caae8c485e4cd01c913b91d14de68b6e701dbe86"
      })
      |> VxUnderground.Samples.create_sample()

    sample
  end
end
