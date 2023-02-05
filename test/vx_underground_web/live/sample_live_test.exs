defmodule VxUndergroundWeb.SampleLiveTest do
  use VxUndergroundWeb.ConnCase

  import Phoenix.LiveViewTest
  import VxUnderground.SamplesFixtures

  @create_attrs %{first_seen: "2023-02-04T17:21:00Z", hash: "some hash", s3_object_key: "some s3_object_key", size: 42, tags: [1, 2], type: "some type"}
  @update_attrs %{first_seen: "2023-02-05T17:21:00Z", hash: "some updated hash", s3_object_key: "some updated s3_object_key", size: 43, tags: [1], type: "some updated type"}
  @invalid_attrs %{first_seen: nil, hash: nil, s3_object_key: nil, size: nil, tags: [], type: nil}

  defp create_sample(_) do
    sample = sample_fixture()
    %{sample: sample}
  end

  describe "Index" do
    setup [:create_sample]

    test "lists all samples", %{conn: conn, sample: sample} do
      {:ok, _index_live, html} = live(conn, ~p"/samples")

      assert html =~ "Listing Samples"
      assert html =~ sample.hash
    end

    test "saves new sample", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/samples")

      assert index_live |> element("a", "New Sample") |> render_click() =~
               "New Sample"

      assert_patch(index_live, ~p"/samples/new")

      assert index_live
             |> form("#sample-form", sample: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#sample-form", sample: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/samples")

      assert html =~ "Sample created successfully"
      assert html =~ "some hash"
    end

    test "updates sample in listing", %{conn: conn, sample: sample} do
      {:ok, index_live, _html} = live(conn, ~p"/samples")

      assert index_live |> element("#samples-#{sample.id} a", "Edit") |> render_click() =~
               "Edit Sample"

      assert_patch(index_live, ~p"/samples/#{sample}/edit")

      assert index_live
             |> form("#sample-form", sample: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#sample-form", sample: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/samples")

      assert html =~ "Sample updated successfully"
      assert html =~ "some updated hash"
    end

    test "deletes sample in listing", %{conn: conn, sample: sample} do
      {:ok, index_live, _html} = live(conn, ~p"/samples")

      assert index_live |> element("#samples-#{sample.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#samples-#{sample.id}")
    end
  end

  describe "Show" do
    setup [:create_sample]

    test "displays sample", %{conn: conn, sample: sample} do
      {:ok, _show_live, html} = live(conn, ~p"/samples/#{sample}")

      assert html =~ "Show Sample"
      assert html =~ sample.hash
    end

    test "updates sample within modal", %{conn: conn, sample: sample} do
      {:ok, show_live, _html} = live(conn, ~p"/samples/#{sample}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Sample"

      assert_patch(show_live, ~p"/samples/#{sample}/show/edit")

      assert show_live
             |> form("#sample-form", sample: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#sample-form", sample: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/samples/#{sample}")

      assert html =~ "Sample updated successfully"
      assert html =~ "some updated hash"
    end
  end
end
