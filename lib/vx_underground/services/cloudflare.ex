defmodule VxUnderground.Services.Cloudflare do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.cloudflare.com/client/v4"

  plug Tesla.Middleware.JSON

  def get_ips() do
    get("/ips")
    |> case do
      {:ok, %{body: %{"result" => %{"ipv4_cidrs" => _, "ipv6_cidrs" => _} = results}}} ->
        {:ok, Map.take(results, ["ipv4_cidrs", "ipv6_cidrs"])}

      _result ->
        {:error, "could not connect to cloudflare"}
    end
  end
end
