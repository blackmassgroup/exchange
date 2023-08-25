defmodule VxUndergroundWeb.Plugs.ApiKeyValidator do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    api_key =
      get_req_header(conn, "authorization")
      |> List.first()
      |> String.replace("Bearer ", "")

    case validate_api_key(api_key) do
      :ok ->
        conn

      :error ->
        conn
        |> send_resp(401, "Unauthorized")
        |> halt()
    end
  end

  defp validate_api_key(api_key) do
    # Your validation logic here. Return :ok if valid, :error if not.
    # For example, you could look up the API key in the database.

    case VxUnderground.Accounts.get_user_by_api_key(api_key) do
      nil -> :error
      _user -> :ok
    end
  end
end
