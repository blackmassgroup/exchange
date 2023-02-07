defmodule VxUnderground.Accounts.DefaultRoles do
  def all() do
    [
      %{
        name: "Admin",
        permissions: %{
          "samples" => ["create", "read", "update", "delete"],
          "roles" => ["read", "update", "update", "delete"],
          "tags" => ["create", "read", "update", "delete"]
        }
      },
      %{
        name: "User",
        permissions: %{
          "samples" => ["create", "read", "update"],
          "tags" => ["create", "read"]
        }
      }
    ]
  end
end
