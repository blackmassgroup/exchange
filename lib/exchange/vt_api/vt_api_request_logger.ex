defmodule Exchange.VtApi.VtApiRequestLogger do
  @behaviour Tesla.Middleware
  alias Exchange.VtApi

  require Logger

  @impl Tesla.Middleware
  def call(env, next, _options) do
    req_body = get_request_body(env)

    with {:ok, api_request} <- VtApi.create_vt_api_request(%{raw_request: req_body, url: env.url}) do
      env
      |> Tesla.run(next)
      |> log_api_response(api_request)
    else
      {:error, %Ecto.Changeset{} = cs} ->
        log_logging_error(cs)

        env
        |> Tesla.run(next)
    end
  end

  defp get_request_body(%{method: "POST", url: "https://www.virustotal.com/api/v3/files"}) do
    "We don't log raw binaries to our database"
  end

  defp get_request_body(%{body: nil, method: method, url: url}) do
    method_string = Atom.to_string(method) |> String.upcase()
    "No Request body, this was a #{method_string} request to #{url}"
  end

  defp get_request_body(%{body: %Tesla.Multipart{parts: [%{body: body}]}}) do
    Base.encode16(body) |> Jason.encode!()
  end

  defp get_request_body(%{body: body}) when is_map(body) do
    Jason.encode!(body)
  end

  defp get_request_body(%{body: body}) do
    body
  end

  @doc """
  Logs the raw response body and HTTP status to the `quote_api_requests` schema.

  Returns the provided `env`.

  Params:
  * `env`: a `%Tesla.Env{}` struct that contains all the request/response data.
  * `api_req`: the `%ApiRequest{}` to be updated with the response data.
  """
  def log_api_response({:ok, params}, api_req) do
    attrs = %{raw_response: Map.get(params, :body), status_code: Map.get(params, :status)}
    {:ok, _} = VtApi.update_vt_api_request(api_req, attrs)

    params = Map.put(params, :request_id, Map.get(api_req, :id))

    {:ok, params}
  end

  def log_api_response({:error, %{reason: reason}} = env, api_req) do
    attrs = %{raw_response: "#{reason}", status_code: reason}
    {:ok, _} = VtApi.update_vt_api_request(api_req, attrs)

    env
  end

  def log_api_response({:error, :timeout} = env, api_req) do
    attrs = %{raw_response: "timeout", status_code: 9999}
    {:ok, _} = VtApi.update_vt_api_request(api_req, attrs)

    env
  end

  def log_api_response({:error, reason} = env, api_req) do
    reason = if is_atom(reason), do: Atom.to_string(reason), else: reason

    attrs = %{raw_response: "#{reason}", status_code: 9999}
    {:ok, _} = VtApi.update_vt_api_request(api_req, attrs)

    env
  end

  @doc """
  Handles a changeset error from logging.
  """
  def log_logging_error(cs) do
    detail =
      Ecto.Changeset.traverse_errors(cs, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)
      |> Enum.flat_map(fn {k, msgs} ->
        Enum.map(msgs, fn msg -> "#{k} #{msg}" end)
      end)
      |> Enum.join("\n")

    msg = "An error occurred logging the API request"

    Logger.error("#{msg}: #{detail}")
  end
end
