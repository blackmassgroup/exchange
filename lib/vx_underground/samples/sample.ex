defmodule VxUnderground.Samples.Sample do
  use Ecto.Schema
  import Ecto.Changeset

  schema "samples" do
    field :first_seen, :utc_datetime
    field :hash, :string
    field :s3_object_key, :string
    field :size, :integer
    field :tags, {:array, :integer}
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(sample, attrs) do
    sample
    |> cast(attrs, [:hash, :size, :type, :first_seen, :s3_object_key])
    |> validate_required([:hash, :size, :type, :first_seen, :s3_object_key])
  end
end
