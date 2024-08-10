defmodule VExchangeWeb.PageControllerTest do
  use VExchangeWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Virus.exchange"
  end
end
