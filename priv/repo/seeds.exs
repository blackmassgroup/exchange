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

VxUnderground.Repo.delete_all(VxUnderground.Accounts.Role)

for role <- VxUnderground.Accounts.DefaultRoles.all() do
  {:ok, _role} = VxUnderground.Accounts.create_role(role)
end
