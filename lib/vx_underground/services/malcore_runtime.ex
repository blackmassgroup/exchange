defmodule VxUnderground.Services.MalcoreRuntime do
  @moduledoc """
  Malcore Virus Scanning

  File upload
  - https://malcore.readme.io/reference/upload
  """
  alias VxUnderground.Services.S3
  alias VxUnderground.Samples
  use Tesla

  @public_url "https://api.malcore.io/"

  plug Tesla.Middleware.BaseUrl, @public_url
  plug Tesla.Middleware.JSON

  def upload(headers, sample_id) do
    client = build_client(headers)

    with sample when sample != nil <- Samples.get_sample(sample_id),
         {:ok, %{body: binary, status_code: 200}} <- S3.get_file_binary(sample.s3_object_key),
         {:ok, %Tesla.Env{body: body, status: 200}} <-
           client |> post("/api/upload", %{}, query: [{sample.s3_object_key, binary}]) do
      {:ok, body}
    else
      {:error, %Tesla.Env{}} ->
        {:error, :failed_to_upload}

      nil ->
        {:error, :does_not_exist}

      _ ->
        {:error, :failed_to_get_binary}
    end
  end

  def register(user_email, headers) do
    client = build_client(headers)
    password = :crypto.strong_rand_bytes(16) |> Base.encode16()

    client
    |> post("/auth/register", %{email: user_email, password: password})
    |> case do
      {:ok, %Tesla.Env{body: _body, status: 200}} ->
        {:ok, reset_password(user_email, headers)}

      _ ->
        {:error, :failed_to_register}
    end
  end

  def reset_password(user_email, headers) do
    client = build_client(headers)

    client
    |> post("/auth/forgot-password", %{email: user_email})
    |> case do
      {:ok, %Tesla.Env{body: _body, status: 200}} ->
        {:ok, :password_reset}

      _ ->
        {:error, :failed_to_reset_password}
    end
  end

  defp build_client(headers) do
    Tesla.client([
      {Tesla.Middleware.Headers, headers},
      {Tesla.Middleware.BaseUrl, @public_url},
      Tesla.Middleware.JSON
    ])
  end
end
