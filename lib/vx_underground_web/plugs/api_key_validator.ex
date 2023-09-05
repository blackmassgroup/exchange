defmodule VxUndergroundWeb.Plugs.ApiKeyValidator do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    api_key =
      get_req_header(conn, "authorization")
      |> List.first()
      |> String.split("Bearer ")
      |> List.last()

    case validate_api_key(api_key) do
      :unauthorized ->
        conn
        |> send_resp(401, "Unauthorized")
        |> halt()

      user ->
        assign(conn, :current_user, user)
    end
  end

  defp validate_api_key(api_key) do
    case VxUnderground.Accounts.get_user_by_api_key(api_key) do
      nil -> :unauthorized
      %{role: %{name: name}} = user when name in ["admin", "uploader"] -> user
      _ -> :unauthorized
    end
  end
end
