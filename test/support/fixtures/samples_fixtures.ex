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
        first_seen: ~U[2023-02-04 17:21:00Z],
        hash: "some hash",
        s3_object_key: "some s3_object_key",
        size: 42,
        tags: [1, 2],
        type: "some type"
      })
      |> VxUnderground.Samples.create_sample()

    sample
  end
end
