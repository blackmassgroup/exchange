defmodule VxUndergroundWeb.Plugs.ApiKeyValidator do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    api_key =
      get_req_header(conn, "authorization")
      |> List.first()
      |> String.split("Bearer ")
      |> List.last()

    case validate_api_key(api_key, conn.request_path) do
      :unauthorized ->
        conn
        |> send_resp(401, "Unauthorized")
        |> halt()

      user ->
        assign(conn, :current_user, user)
    end
  end

  defp validate_api_key(api_key, request_path) do
    case VxUnderground.Accounts.get_user_by_api_key(api_key) do
      nil ->
        :unauthorized

      %{role: %{name: name}} = user when name in ["Admin", "Uploader"] ->
        user

      %{role: %{name: "User"}} = user
      when request_path not in ["/api/samples/new", "/api/upload"] ->
        user

      _ ->
        :unauthorized
    end
  end
end
