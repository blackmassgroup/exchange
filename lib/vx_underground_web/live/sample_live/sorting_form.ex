defmodule VxUndergroundWeb.SampleLive.SortingForm do
  import Ecto.Changeset

  alias VxUndergroundWeb.Live.EctoHelper

  @fields %{
    sort_by: EctoHelper.enum([:Hash, :Size, :Type, :"First seen", :"S3 object key", :tags]),
    sort_dir: EctoHelper.enum([:asc, :desc])
  }

  @default_values %{
    sort_by: :Size,
    sort_dir: :desc
  }

  def handle_info({:update, opts}, socket) do
    send(self(), {:update, opts})

    {:noreply, socket}
  end

  def parse(params) do
    {@default_values, @fields}
    |> cast(params, Map.keys(@fields))
    |> apply_action(:insert)
  end

  def default_values(), do: @default_values
end
