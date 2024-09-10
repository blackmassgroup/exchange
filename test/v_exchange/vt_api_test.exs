defmodule Exchange.VtApiTest do
  use Exchange.DataCase

  alias Exchange.VtApi

  describe "vt_api_requests" do
    alias Exchange.VtApi.VtApiRequest

    import Exchange.VtApiFixtures

    @invalid_attrs %{raw_request: nil, raw_response: nil, http_response_code: nil}

    test "list_vt_api_requests/0 returns all vt_api_requests" do
      vt_api_request = vt_api_request_fixture()
      assert VtApi.list_vt_api_requests() == [vt_api_request]
    end

    test "get_vt_api_request!/1 returns the vt_api_request with given id" do
      vt_api_request = vt_api_request_fixture()
      assert VtApi.get_vt_api_request!(vt_api_request.id) == vt_api_request
    end

    test "create_vt_api_request/1 with valid data creates a vt_api_request" do
      valid_attrs = %{
        raw_request: "some raw_request",
        raw_response: "some raw_response",
        http_response_code: 42,
        url: "some url"
      }

      assert {:ok, %VtApiRequest{} = vt_api_request} = VtApi.create_vt_api_request(valid_attrs)
      assert vt_api_request.raw_request == "some raw_request"
      assert vt_api_request.raw_response == "some raw_response"
      assert vt_api_request.http_response_code == 42
    end

    test "create_vt_api_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = VtApi.create_vt_api_request(@invalid_attrs)
    end

    test "update_vt_api_request/2 with valid data updates the vt_api_request" do
      vt_api_request = vt_api_request_fixture()

      update_attrs = %{
        raw_request: "some updated raw_request",
        raw_response: "some updated raw_response",
        http_response_code: 43
      }

      assert {:ok, %VtApiRequest{} = vt_api_request} =
               VtApi.update_vt_api_request(vt_api_request, update_attrs)

      assert vt_api_request.raw_request == "some updated raw_request"
      assert vt_api_request.raw_response == "some updated raw_response"
      assert vt_api_request.http_response_code == 43
    end

    test "update_vt_api_request/2 with invalid data returns error changeset" do
      vt_api_request = vt_api_request_fixture()

      assert {:error, %Ecto.Changeset{}} =
               VtApi.update_vt_api_request(vt_api_request, @invalid_attrs)

      assert vt_api_request == VtApi.get_vt_api_request!(vt_api_request.id)
    end

    test "delete_vt_api_request/1 deletes the vt_api_request" do
      vt_api_request = vt_api_request_fixture()
      assert {:ok, %VtApiRequest{}} = VtApi.delete_vt_api_request(vt_api_request)
      assert_raise Ecto.NoResultsError, fn -> VtApi.get_vt_api_request!(vt_api_request.id) end
    end

    test "change_vt_api_request/1 returns a vt_api_request changeset" do
      vt_api_request = vt_api_request_fixture()
      assert %Ecto.Changeset{} = VtApi.change_vt_api_request(vt_api_request)
    end
  end
end
