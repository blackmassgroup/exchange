defmodule VExchangeWeb.SampleLiveTest do
  use VExchangeWeb.ConnCase

  @moduletag capture_log: true

  import Phoenix.LiveViewTest
  import VExchange.SamplesFixtures

  @create_attrs %{
    names: ["Test Name"],
    first_seen: ~U[2023-02-05 17:21:00Z],
    s3_object_key: "some new s3_object_key",
    size: 43,
    tags: ["tag"],
    type: "some new type",
    md5: "8f1e3ebe78bf1e81b9d278dfdf278f24",
    sha1: "261ce8aa87bd3c520c577290ce3073d83509e343",
    sha256: "adf8e94bced4691aadc5b7695116929289623cd925bbf087165c6a7e6e3dd6e2",
    sha512:
      "38ae7e95990689ff4f209f765452a164ef22ce5fd805ebc185278b8aa03196b3f7e76df17da6d755d3e4cd58caae8c485e4cd01c913b91d14de68b6e701dbe81"
  }

  # @update_attrs %{
  #   names: ["updated Test Name"],
  #   first_seen: ~U[2023-02-05 17:21:00Z],
  #   s3_object_key: "some updated s3_object_key",
  #   size: 43,
  #   tags: [%VExchange.Tags.Tag{name: "Test"}],
  #   type: "some updated type",
  #   md5: "8f1e3ebe78bf1e81b9d278dfdf278f2f",
  #   sha1: "261ce8aa87bd3c520c577290ce3073d83509e34a",
  #   sha256: "adf8e94bced4691aadc5b7695116929289623cd925bbf087165c6a7e6e3dd6e5",
  #   sha512:
  #     "38ae7e95990689ff4f209f765452a164ef22ce5fd805ebc185278b8aa03196b3f7e76df17da6d755d3e4cd58caae8c485e4cd01c913b91d14de68b6e701dbe83"
  # }

  @invalid_attrs %{first_seen: nil, s3_object_key: nil, size: nil, tags: [], type: nil}

  defp create_sample(_) do
    sample = sample_fixture()
    %{sample: sample}
  end

  defp login_admin_user(%{conn: conn}) do
    {:ok, user} =
      VExchange.Accounts.register_user(%{email: "test@test.com", password: "Password123!"})

    {:ok, admin_user} = VExchange.Accounts.add_role_to_user(user, "Admin")

    conn =
      conn
      |> Map.replace!(:secret_key_base, VExchangeWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{
      conn: VExchangeWeb.ConnCase.log_in_user(conn, admin_user)
    }
  end

  describe "Index" do
    setup [:create_sample, :login_admin_user]
    @tag :skip
    test "lists all samples", %{conn: conn, sample: sample} do
      {:ok, _index_live, html} = live(conn, ~p"/samples")

      assert html =~ "Listing Samples"
      assert html =~ sample.sha1
    end

    @tag :skip
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

    @tag :skip
    test "deletes sample in listing", %{conn: conn, sample: sample} do
      {:ok, index_live, _html} = live(conn, ~p"/samples")

      assert index_live |> element("#samples-#{sample.id} a", "Delete") |> render_click()

      refute has_element?(index_live, "#samples-#{sample.id}")
    end
  end

  describe "Show" do
    setup [:create_sample, :login_admin_user]

    @tag :skip
    test "displays sample", %{conn: conn, sample: sample} do
      {:ok, _show_live, html} = live(conn, ~p"/samples/#{sample}")

      assert html =~ "Show Sample"
      assert html =~ sample.sha1
    end
  end
end
