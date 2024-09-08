defmodule VExchangeWeb.SampleController do
  use VExchangeWeb, :controller

  action_fallback VExchangeWeb.FallbackController

  plug VExchangeWeb.Plugs.ApiKeyValidator

  require Logger

  alias VExchange.Samples

  def show(conn, %{"sha256" => sha256}) do
    case VExchange.Samples.get_sample_by_sha256(sha256) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(html: VExchangeWeb.ErrorHTML, json: VExchangeWeb.ErrorJSON)
        |> render(:"404")

      sample ->
        conn
        |> put_status(:ok)
        |> render(:show, sample: sample)
    end
  end

  def create(conn, %{"file" => %Plug.Upload{path: path, filename: filename}} = _params) do
    case File.read(path) do
      {:ok, file} ->
        user_id = conn.assigns.current_user.id

        Samples.create_from_binary(%{"file" => file, "filename" => filename}, user_id)
        |> case do
          {:ok, sample} ->
            conn
            |> put_status(:created)
            |> render(:show_id, sample: sample)

          {:error, %Ecto.Changeset{}} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(json: VExchangeWeb.ErrorJSON)
            |> render(:"422")

          {:error, :too_large} ->
            conn
            |> put_status(:request_entity_too_large)
            |> put_view(json: VExchangeWeb.ErrorJSON)
            |> render(:"413")

          {:error, :duplicate} ->
            conn
            |> put_status(:conflict)
            |> put_view(json: VExchangeWeb.ErrorJSON)
            |> render(:"409")

          err ->
            "SampleController.create - User: #{inspect(conn.assigns.current_user.email)} - create_from_binary: #{inspect(err)}"
            |> Logger.error()

            conn
            |> put_status(500)
            |> put_view(json: VExchangeWeb.ErrorJSON)
            |> render(:"500")
        end

      err ->
        "SampleController.create - User: #{inspect(conn.assigns.current_user.email)} - Couldn't read file: #{inspect(err)}"
        |> Logger.error()

        conn
        |> put_view(html: VExchangeWeb.ErrorHTML, json: VExchangeWeb.ErrorJSON)
        |> render(:"500")
    end
  end

  def create(conn, params) do
    "SampleController.create - User: #{inspect(conn.assigns.current_user.email)} - Invalid params: #{inspect(params)}"
    |> Logger.error()

    conn
    |> put_status(:bad_request)
    |> put_view(html: VExchangeWeb.ErrorHTML, json: VExchangeWeb.ErrorJSON)
    |> render(:"400")
  end
end
