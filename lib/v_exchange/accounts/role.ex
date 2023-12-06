defmodule VExchange.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset

  alias VExchange.Accounts

  schema "roles" do
    field(:name, :string)
    field(:permissions, :map)

    has_many(:users, Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :permissions])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> validate_at_least_one_permission()
    |> Accounts.Permissions.validate_permissions(:permissions)
  end

  defp validate_at_least_one_permission(changeset) do
    validate_change(changeset, :permissions, fn field, permissions ->
      if map_size(permissions) == 0 do
        [{field, "must have at least one permission"}]
      else
        []
      end
    end)
  end
end
