defmodule ExchangeWeb.UserApiSessionController do
  use ExchangeWeb, :controller
  action_fallback ExchangeWeb.FallbackController

  alias Exchange.Accounts

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
