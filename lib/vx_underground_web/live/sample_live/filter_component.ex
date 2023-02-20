defmodule VxUndergroundWeb.SampleLive.FilterComponent do
  use VxUndergroundWeb, :live_component

  alias VxUndergroundWeb.SampleLive.FilterForm

  def render(assigns) do
    ~H"""
    <div id="table-filter">
      <.form
        :let={f}
        for={@changeset}
        as={:filter}
        phx-change="search"
        phx-submit="search"
        phx-target={@myself}
      >
        <div class="pt-1 flex">
          <div class="w-64">
            <div class="relative z-0 mb-3 group">
              <%= for filter <- @changeset.data |> Map.keys() do %>
                <.focus_wrap id="focus-wrap">
                  <.input field={{f, filter}} label={} />
                </.focus_wrap>
              <% end %>
            </div>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, assign_changeset(assigns, socket)}
  end

  def handle_event("search", %{"filter" => filter}, socket) do
    case FilterForm.parse(filter) do
      {:ok, opts} ->
        send(self(), {:update, opts})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp assign_changeset(%{filter: filter}, socket) do
    assign(socket, :changeset, FilterForm.change_values(filter))
  end
end
