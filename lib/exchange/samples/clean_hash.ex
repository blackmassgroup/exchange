defmodule Exchange.Samples.CleanHash do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clean_hashes" do
    field :sha256, :string

    timestamps()
  end

  @doc false
  def changeset(clean_hash, attrs) do
    clean_hash
    |> cast(attrs, [:sha256])
    |> validate_required([:sha256])
  end
end
