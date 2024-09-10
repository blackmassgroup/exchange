defmodule ExchangeWeb.SampleChannel do
  use ExchangeWeb, :channel

  @impl true
  def join("sample:lobby", _payload, socket) do
    if authorized?(socket) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def broadcast(msg, payload),
    do: ExchangeWeb.Endpoint.broadcast("sample:lobby", msg, payload)

  defp authorized?(%{assigns: %{current_user: nil}}), do: false
  defp authorized?(_socket), do: true
end
