defmodule VxUndergroundWeb.RoleLiveTest do
  use VxUndergroundWeb.ConnCase

  import Phoenix.LiveViewTest
  import VxUnderground.AccountsFixtures

  @create_attrs %{name: "some name", permissions: %{}}
  @update_attrs %{name: "some updated name", permissions: %{}}
  @invalid_attrs %{name: nil, permissions: nil}

  defp create_role(_) do
    role = role_fixture()
    %{role: role}
  end

  describe "Index" do
    setup [:create_role]

    test "lists all roles", %{conn: conn, role: role} do
      {:ok, _index_live, html} = live(conn, ~p"/roles")

      assert html =~ "Listing Roles"
      assert html =~ role.name
    end

    test "saves new role", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/roles")

      assert index_live |> element("a", "New Role") |> render_click() =~
               "New Role"

      assert_patch(index_live, ~p"/roles/new")

      assert index_live
             |> form("#role-form", role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#role-form", role: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/roles")

      assert html =~ "Role created successfully"
      assert html =~ "some name"
    end

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

    test "deletes role in listing", %{conn: conn, role: role} do
      {:ok, index_live, _html} = live(conn, ~p"/roles")

      assert index_live |> element("#roles-#{role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#roles-#{role.id}")
    end
  end

  describe "Show" do
    setup [:create_role]

    test "displays role", %{conn: conn, role: role} do
      {:ok, _show_live, html} = live(conn, ~p"/roles/#{role}")

      assert html =~ "Show Role"
      assert html =~ role.name
    end

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
