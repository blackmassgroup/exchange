defmodule VExchange.CleanHashesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VExchange.CleanHashes` context.
  """

  @doc """
  Generate a clean_hash.
  """
  def clean_hash_fixture(attrs \\ %{}) do
    {:ok, clean_hash} =
      attrs
      |> Enum.into(%{
        sha256: "some sha256"
      })
      |> VExchange.CleanHashes.create_clean_hash()

    clean_hash
  end
end
