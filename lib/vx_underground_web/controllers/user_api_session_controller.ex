defmodule VxUndergroundWeb.UserApiSessionController do
  use VxUndergroundWeb, :controller
  action_fallback VxUndergroundWeb.FallbackController

  alias VxUnderground.Accounts

  def create(conn, %{"email" => email, "password" => password} = _params) do
    case Accounts.get_user_by_email_and_password(email, password) do
      nil ->
        {:error, "Invalid email or password"}

      user ->
        conn
        |> put_status(:created)
        |> render(:show, user: user)
    end
  end
end
