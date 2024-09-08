defmodule VExchange.MalformedSamples.MalformedSample do
  use Ecto.Schema
  import Ecto.Changeset

  schema "malformed_samples" do
    field :sha256, :string
    field :beginning, :string
    field :sample_id, :id

    timestamps()
  end

  @doc false
  def changeset(malformed_sample, attrs) do
    malformed_sample
    |> cast(attrs, [:sha256, :beginning])
    |> validate_required([:sha256])
  end
end
