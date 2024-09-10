defmodule Exchange.ApiBodyReader do
  @upload_paths ["/api/upload", "/api/samples/new"]

  @doc """
  Reads the body of the request and updates the connection params.
  """
  def read_body(%Plug.Conn{request_path: path} = conn, opts) when path in @upload_paths do
    size = Exchange.Samples.size_limit()
    addl_opts = [read_length: size, length: size, read_timeout: 20_000]
    opts = Keyword.merge(opts, addl_opts)

    Plug.Conn.read_body(conn, opts)
    |> handle_read(conn, addl_opts)
  end

  def read_body(conn, opts) do
    Plug.Conn.read_body(conn, opts)
  end

  defp handle_read({:ok, body, conn}, _conn, _opts) do
    conn = update_params(conn, body)
    {:ok, "", conn}
  end

  defp handle_read({:more, partial_body, conn}, _original_conn, _opts) do
    # {:ok, body, conn} = read_body(conn, opts)
    conn = update_params(conn, partial_body)
    {:ok, "", conn}
  end

  defp handle_read({:error, _reason}, conn, _opts) do
    {:ok, "", conn}
  end

  defp update_params(conn, body) do
    params = %{"file" => body}
    Map.put(conn, :params, params)
  end
end
