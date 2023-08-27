defmodule VxUndergroundWeb.QueryCache do
  use GenServer
  alias VxUnderground.Samples

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    :ets.new(:query_cache, [:named_table])
    refresh_value()
    {:ok, %{}}
  end

  def query_database do
    samples = Samples.quick_list_samples()

    count =
      Samples.get_sample_count!()
      |> Number.Delimit.number_to_delimited(delimiter: ",", precision: 0)

    %{samples: samples, count: count}
  end

  def refresh_value() do
    %{samples: samples, count: count} = query_database()

    :ets.insert(:query_cache, {:samples, samples})
    :ets.insert(:query_cache, {:count, count})

    :ok
  end

  def update do
    GenServer.cast(__MODULE__, :update)
  end

  def handle_cast(:update, state) do
    refresh_value()

    {:noreply, state}
  end

  def handle_info(:update, state) do
    refresh_value()

    {:noreply, state}
  end

  def fetch_value do
    with(
      [{:samples, samples}] <- :ets.lookup(:query_cache, :samples),
      [{:count, count}] <- :ets.lookup(:query_cache, :count)
    ) do
      %{samples: samples, count: count}
    else
      _ ->
        update()
        fetch_value()
    end
  end
end
