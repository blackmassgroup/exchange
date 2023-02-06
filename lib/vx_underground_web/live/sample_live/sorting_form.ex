defmodule VxUndergroundWeb.SampleLive.SortingForm do
  import Ecto.Changeset

  alias VxUndergroundWeb.Live.EctoHelper

  @fields %{
    sort_by: EctoHelper.enum([:id, :hash, :size, :type, :first_seen]),
    sort_dir: EctoHelper.enum([:asc, :desc])
  }

  @default_vaules %{
    sort_by: :first_seen,
    sort_dir: :desc
  }

  def handle_info({:update, opts}, socket) do
    send(self(), {:update, opts})

    {:noreply, socket}
  end

  def parse(params) do
    {@default_vaules, @fields}
    |> cast(params, Map.keys(@fields))
    |> apply_action(:insert)
  end

  def default_vaules(), do: @default_vaules
end
