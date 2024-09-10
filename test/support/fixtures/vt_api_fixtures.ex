defmodule Exchange.VtApiFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Exchange.VtApi` context.
  """

  @doc """
  Generate a vt_api_request.
  """
  def vt_api_request_fixture(attrs \\ %{}) do
    {:ok, vt_api_request} =
      attrs
      |> Enum.into(%{
        http_response_code: 42,
        raw_request: "some raw_request",
        raw_response: "some raw_response",
        url: "some url"
      })
      |> Exchange.VtApi.create_vt_api_request()

    vt_api_request
  end
end
