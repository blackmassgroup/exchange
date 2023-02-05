defmodule VxUnderground.TagsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VxUnderground.Tags` context.
  """

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        kind: "some kind",
        name: "some name"
      })
      |> VxUnderground.Tags.create_tag()

    tag
  end
end
