defmodule ExchangeWeb.Plugs.MaintenanceMode do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if Application.get_env(:exchange, :maintenance_mode, false) do
      case get_format(conn) do
        "json" ->
          conn
          |> put_status(503)
          |> json(%{error: "Service temporarily unavailable for maintenance"})
          |> halt()

        _ ->
          conn
          |> put_status(503)
          |> put_layout(html: {ExchangeWeb.Layouts, :root})
          |> put_view(ExchangeWeb.ErrorHTML)
          |> render("503.html")
          |> halt()
      end
    else
      conn
    end
  end
end
