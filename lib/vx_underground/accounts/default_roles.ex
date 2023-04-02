defmodule VxUnderground.Accounts.DefaultRoles do
  def all() do
    [
      %{
        name: "Admin",
        permissions: %{
          "samples" => ["create", "read", "update", "delete"],
          "roles" => ["create", "read", "update", "delete"],
          "tags" => ["create", "read", "update", "delete"],
          "users" => ["create", "read", "update", "delete"]
        }
      },
      %{
        name: "User",
        permissions: %{
          "samples" => ["read"],
          "tags" => ["read"]
        }
      },
      %{
        name: "Uploader",
        permissions: %{
          "samples" => ["create", "read", "update"],
          "tags" => ["create", "read", "update"]
        }
      }
    ]
  end
end
