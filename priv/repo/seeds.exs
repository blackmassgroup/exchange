# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     VxUnderground.Repo.insert!(%VxUnderground.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
for role <- VxUnderground.Accounts.DefaultRoles.all() do
  unless VxUnderground.Accounts.get_role_by_name(role.name) do
    {:ok, _role} = VxUnderground.Accounts.create_role(role)
  end
end
