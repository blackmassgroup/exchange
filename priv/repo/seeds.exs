# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     VExchange.Repo.insert!(%VExchange.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
for role <- VExchange.Accounts.DefaultRoles.all() do
  unless VExchange.Accounts.get_role_by_name!(role.name) do
    {:ok, _role} = VExchange.Accounts.create_role(role)
  end
end
