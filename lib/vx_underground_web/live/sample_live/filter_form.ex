defmodule VxUndergroundWeb.SampleLive.FilterForm do
  import Ecto.Changeset

  @fields %{
    hash: :string
  }

  @default_vaules %{
    hash: nil
  }

  def default_vaules(overrides \\ %{}) do
    Map.merge(@default_vaules, overrides)
  end

  def parse(params) do
    {@default_vaules, @fields}
    |> cast(params, Map.keys(@fields))
    # |> validate_number(:id, greater_than_or_equal_to: 0)
    |> apply_action(:insert)
  end

  def change_values(values \\ @default_vaules) do
    {values, @fields}
    |> cast(%{}, Map.keys(@fields))
  end
end
