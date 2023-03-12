defmodule VxUndergroundWeb.TagLiveTest do
  use VxUndergroundWeb.ConnCase

  import Phoenix.LiveViewTest
  import VxUnderground.TagsFixtures

  @create_attrs %{kind: "some kind", name: "some name"}
  @update_attrs %{kind: "some updated kind", name: "some updated name"}
  @invalid_attrs %{kind: nil, name: nil}

  defp create_tag(_) do
    tag = tag_fixture()
    %{tag: tag}
  end

  defp login_admin_user(%{conn: conn}) do
    {:ok, user} =
      VxUnderground.Accounts.register_user(%{email: "test@test.com", password: "Password123!"})

    {:ok, admin_user} = VxUnderground.Accounts.add_role_to_user(user, "Admin")

    conn =
      conn
      |> Map.replace!(:secret_key_base, VxUndergroundWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{
      conn: VxUndergroundWeb.ConnCase.log_in_user(conn, admin_user)
    }
  end

  describe "Index" do
    setup [:create_tag, :login_admin_user]

    test "lists all tags", %{conn: conn, tag: tag} do
      {:ok, _index_live, html} = live(conn, ~p"/tags")

      assert html =~ "Listing Tags"
      assert html =~ tag.kind
    end

    test "saves new tag", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/tags")

      assert index_live |> element("a", "New Tag") |> render_click() =~
               "New Tag"

      assert_patch(index_live, ~p"/tags/new")

      assert index_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#tag-form", tag: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/tags")

      assert html =~ "Tag created successfully"
      assert html =~ "some kind"
    end

    test "updates tag in listing", %{conn: conn, tag: tag} do
      {:ok, index_live, _html} = live(conn, ~p"/tags")

      assert index_live |> element("#tags-#{tag.id} a", "Edit") |> render_click() =~
               "Edit Tag"

      assert_patch(index_live, ~p"/tags/#{tag}/edit")

      assert index_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#tag-form", tag: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/tags")

      assert html =~ "Tag updated successfully"
      assert html =~ "some updated kind"
    end

    test "deletes tag in listing", %{conn: conn, tag: tag} do
      {:ok, index_live, _html} = live(conn, ~p"/tags")

      assert index_live |> element("#tags-#{tag.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tags-#{tag.id}")
    end
  end

  describe "Show" do
    setup [:create_tag, :login_admin_user]

    test "displays tag", %{conn: conn, tag: tag} do
      {:ok, _show_live, html} = live(conn, ~p"/tags/#{tag}")

      assert html =~ "Show Tag"
      assert html =~ tag.kind
    end

    test "updates tag within modal", %{conn: conn, tag: tag} do
      {:ok, show_live, _html} = live(conn, ~p"/tags/#{tag}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Tag"

      assert_patch(show_live, ~p"/tags/#{tag}/show/edit")

      assert show_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#tag-form", tag: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/tags/#{tag}")

      assert html =~ "Tag updated successfully"
      assert html =~ "some updated kind"
    end
  end
end
