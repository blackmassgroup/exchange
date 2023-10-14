defmodule VxUndergroundWeb.ApiBodyReader do
  def read_body(%Plug.Conn{request_path: "/api/upload"} = conn, opts) do
    new_opts = [read_length: 52_000_000, length: 52_000_000, read_timeout: 20_000]
    opts = Keyword.merge(opts, new_opts)

    {:ok, body, conn} =
      Plug.Conn.read_body(conn, opts)
      |> case do
        {:ok, body, conn} -> {:ok, body, conn}
        {:more, data} {:ok, data, conn}
      end

    params = %{"file" => body}
    conn = Map.put(conn, :params, params)

    {:ok, "", conn}
  end

  def read_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    {:ok, body, conn}
  end
end
