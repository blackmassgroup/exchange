defmodule VExchange.Repo.Local.Migrations.AddAiKeysToExistingUsers do
  use Ecto.Migration
  alias VExchange.Accounts.User
  alias VExchange.Repo.Local, as: Repo

  def up do
    VExchange.Accounts.list_users()
    |> Enum.each(fn
      %{api_key: nil} = user ->
        User.api_key_changeset(user, %{api_key: generate_api_key()}) |> Repo.update!()

      _ ->
        :ok
    end)
  end

  def down do
  end

  def generate_api_key() do
    :crypto.strong_rand_bytes(32)
    |> Base.encode64()
    |> String.replace("/", "0")
    |> String.slice(0, 32)
  end
end
