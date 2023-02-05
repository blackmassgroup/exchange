defmodule VxUndergroundWeb.SampleLive.Index do
  use VxUndergroundWeb, :live_view

  alias VxUnderground.Samples
  alias VxUnderground.Samples.Sample

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :samples, list_samples())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Sample")
    |> assign(:sample, Samples.get_sample!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Sample")
    |> assign(:sample, %Sample{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Samples")
    |> assign(:sample, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    sample = Samples.get_sample!(id)
    {:ok, _} = Samples.delete_sample(sample)

    {:noreply, assign(socket, :samples, list_samples())}
  end

  defp list_samples do
    Samples.list_samples()
  end
end
