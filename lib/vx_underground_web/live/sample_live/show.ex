defmodule VxUndergroundWeb.SampleLive.Show do
  use VxUndergroundWeb, :live_view

  alias VxUnderground.{Samples, Tags}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:sample, Samples.get_sample!(id))
     |> assign(:tags, Tags.list_tags() |> Enum.map(&[value: &1.id, key: &1.name]))}
  end

  defp page_title(:show), do: "Show Sample"
  defp page_title(:edit), do: "Edit Sample"
end
