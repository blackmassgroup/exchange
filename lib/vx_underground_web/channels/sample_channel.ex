defmodule VxUndergroundWeb.SampleChannel do
  use VxUndergroundWeb, :channel

  @impl true
  def join("sample:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def broadcast(msg, payload),
    do: VxUndergroundWeb.Endpoint.broadcast("sample:lobby", msg, payload)

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
