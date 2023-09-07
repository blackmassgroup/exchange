defmodule VxUnderground.Services.CloudflareEts do
  @moduledoc """
  IP filtering logic to allow only Cloudflare IPs.
  I know your not supposed to use Genservers like this but I don't care right now
  """
  alias VxUnderground.Services.Cloudflare
  use GenServer

  @ets_table_name :cloudflare_ips

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
    create_table_if_dne()
    populate_ets()
    {:ok, %{}}
  end

  defp populate_ets do
    {:ok, %{"ipv4_cidrs" => ipv4, "ipv6_cidrs" => ipv6}} = Cloudflare.get_ips()

    :ets.insert(@ets_table_name, {:ipv4, ipv4})

    :ets.insert(@ets_table_name, {:ipv6, ipv6})
  end

  def get_ips() do
    create_table_if_dne()
    GenServer.call(__MODULE__, :get_ips)
  end

  def handle_call(:get_ips, _from, state) do
    with(
      [{:ipv4, ipv4}] <- :ets.lookup(@ets_table_name, :ipv4),
      [{:ipv6, ipv6}] <- :ets.lookup(@ets_table_name, :ipv6)
    ) do
      {:reply, %{ipv4: ipv4, ipv6: ipv6}, state}
    end
  end

  defp create_table_if_dne() do
    case :ets.whereis(@ets_table_name) do
      :undefined -> :ets.new(@ets_table_name, [:named_table])
      _ -> :ok
    end
  end
end
