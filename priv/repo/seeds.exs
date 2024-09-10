# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Exchange.Repo.insert!(%Exchange.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
for role <- Exchange.Accounts.DefaultRoles.all() do
  unless Exchange.Accounts.get_role_by_name!(role.name) do
    {:ok, _role} = Exchange.Accounts.create_role(role)
  end
end
