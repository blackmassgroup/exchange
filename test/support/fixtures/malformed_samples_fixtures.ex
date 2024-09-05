defmodule VExchange.MalformedSamplesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VExchange.MalformedSamples` context.
  """

  @doc """
  Generate a malformed_sample.
  """
  def malformed_sample_fixture(attrs \\ %{}) do
    {:ok, malformed_sample} =
      attrs
      |> Enum.into(%{
        sha256: "some sha256"
      })
      |> VExchange.MalformedSamples.create_malformed_sample()

    malformed_sample
  end
end
