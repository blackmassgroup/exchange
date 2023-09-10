defmodule VxUndergroundWeb.Plugs.CloudflareIpValidator do
  require Logger
  alias VxUnderground.Services.CloudflareEts

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    [raw_remote_ip] = Plug.Conn.get_req_header(conn, "fly-client-ip")

    remote_ip =
      raw_remote_ip
      |> InetCidr.parse_address!()

    %{ipv4: ipv4, ipv6: ipv6} = CloudflareEts.get_ips()

    if ip_in_range?(remote_ip, ipv4) or ip_in_range?(remote_ip, ipv6) do
      conn
    else
      conn
      |> Plug.Conn.send_resp(403, "Forbidden")
      |> Plug.Conn.halt()
    end
  end

  defp ip_in_range?(ip, ranges) do
    Enum.any?(ranges, fn range ->
      range = InetCidr.parse(range)

      InetCidr.contains?(range, ip)
    end)
  end
end
