defmodule VExchangeWeb.RoleLiveTest do
  use VExchangeWeb.ConnCase

  import Phoenix.LiveViewTest

  @create_attrs %{
    name: "some name",
    permissions:
      %{
        "samples" => ["create", "read", "update"],
        "tags" => ["create", "read"]
      }
      |> Jason.encode!()
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil, permissions: %{}}

  defp login_admin_user(%{conn: conn}) do
    {:ok, user} =
      VExchange.Accounts.register_user(%{email: "test@test.com", password: "Password123!"})

    {:ok, admin_user} = VExchange.Accounts.add_role_to_user(user, "Admin")

    conn =
      conn
      |> Map.replace!(:secret_key_base, VExchangeWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{
      conn: VExchangeWeb.ConnCase.log_in_user(conn, admin_user),
      role: VExchange.Accounts.get_role!(1)
    }
  end

  describe "Index" do
    setup [:login_admin_user]

    test "lists all roles", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/roles")

      assert html =~ "Listing Roles"
    end

    @tag :skip
    test "saves new role", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/roles")

      assert index_live |> element("a", "New Role") |> render_click() =~
               "New Role"

      assert_patch(index_live, ~p"/roles/new")

      assert index_live
             |> form("#role-form", role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _view, html} =
        index_live
        |> form("#role-form", role: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/roles")

      assert html =~ "Role created successfully"
      assert html =~ "some name"
    end

    @tag :skip
    test "updates role in listing", %{conn: conn, role: role} do
      {:ok, index_live, _html} = live(conn, ~p"/roles")

      assert index_live |> element("#roles-#{role.id} a", "Edit") |> render_click() =~
               "Edit Role"

      assert_patch(index_live, ~p"/roles/#{role}/edit")

      assert index_live
             |> form("#role-form", role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#role-form", role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/roles")

      assert html =~ "Role updated successfully"
      assert html =~ "some updated name"
    end

    @tag :skip
    test "deletes role in listing", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/roles")
      role = VExchange.Accounts.get_role_by_name!("User")

      assert index_live |> element("#roles-#{role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#roles-#{role.id}")
    end
  end

  describe "Show" do
    setup [:login_admin_user]

    test "displays role", %{conn: conn, role: role} do
      {:ok, _show_live, html} = live(conn, ~p"/roles/#{role}")

      assert html =~ "Show Role"
      assert html =~ role.name
    end

    @tag :skip
    test "updates role within modal", %{conn: conn, role: role} do
      {:ok, show_live, _html} = live(conn, ~p"/roles/#{role}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Role"

      assert_patch(show_live, ~p"/roles/#{role}/show/edit")

      assert show_live
             |> form("#role-form", role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#role-form", role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/roles/#{role}")

      assert html =~ "Role updated successfully"
      assert html =~ "some updated name"
    end
  end
end
