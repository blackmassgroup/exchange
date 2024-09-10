defmodule Exchange.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Exchange.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "Hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      malcore: "false"
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Exchange.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  @doc """
  Generate a role.
  """
  def role_fixture(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{
        name: "some name",
        permissions: %{
          "samples" => ["create", "read", "update", "delete"],
          "roles" => ["read", "update", "update", "delete"],
          "tags" => ["create", "read", "update", "delete"]
        }
      })
      |> Exchange.Accounts.create_role()

    role
  end

  def admin_role_fixture(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{
        name: "Admin",
        permissions: %{
          "samples" => ["create", "read", "update", "delete"],
          "roles" => ["read", "update", "update", "delete"],
          "tags" => ["create", "read", "update", "delete"]
        }
      })
      |> Exchange.Accounts.create_role()

    role
  end
end
