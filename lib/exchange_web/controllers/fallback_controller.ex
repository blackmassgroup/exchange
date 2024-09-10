defmodule ExchangeWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ExchangeWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ExchangeWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: ExchangeWeb.ErrorHTML, json: ExchangeWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, "Invalid email or password"}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(html: ExchangeWeb.ErrorHTML, json: ExchangeWeb.ErrorJSON)
    |> render(:"401")
  end

  def call(conn, {:error, _}) do
    conn
    |> put_status(500)
    |> put_view(html: ExchangeWeb.ErrorHTML, json: ExchangeWeb.ErrorJSON)
    |> render(:"500")
  end
end
