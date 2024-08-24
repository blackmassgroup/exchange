defmodule VExchangeWeb.SampleController do
  use VExchangeWeb, :controller

  action_fallback VExchangeWeb.FallbackController

  plug VExchangeWeb.Plugs.ApiKeyValidator

  alias VExchange.Services.S3
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

  def create(conn, %{"file" => file} = _params) do
    VExchange.Repo.transaction(fn ->
      with true <- Samples.is_below_size_limit(file),
           params <- Samples.build_sample_params(file),
           {:ok, sample} <- Samples.create_sample(params),
           {:ok, _sample} <- S3.put_object(sample.s3_object_key, file, :wasabi),
           {:ok, _} = S3.copy_file_to_daily_backups(sample.sha256) do
        sample
      else
        {:error, %Ecto.Changeset{}} -> VExchange.Repo.rollback(:invalid_sample)
        false -> VExchange.Repo.rollback(:too_large)
        _ -> VExchange.Repo.rollback(:cloud_provider_error)
      end
    end)
    |> case do
      {:ok, sample} ->
        conn
        |> put_status(:created)
        |> render(:show_id, sample: sample)

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(html: VExchangeWeb.ErrorHTML, json: VExchangeWeb.ErrorJSON)
        |> render(:"422")

      {:error, :too_large} ->
        conn
        |> put_status(:request_entity_too_large)
        |> put_view(html: VExchangeWeb.ErrorHTML, json: VExchangeWeb.ErrorJSON)
        |> render(:"413")

      _ ->
        conn
        |> put_status(500)
        |> put_view(html: VExchangeWeb.ErrorHTML, json: VExchangeWeb.ErrorJSON)
        |> render(:"500")
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> put_view(html: VExchangeWeb.ErrorHTML, json: VExchangeWeb.ErrorJSON)
    |> render(:"400")
  end
end
