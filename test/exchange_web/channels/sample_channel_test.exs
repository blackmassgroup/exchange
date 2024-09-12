defmodule ExchangeWeb.SampleChannelTest do
  use ExchangeWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      ExchangeWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(ExchangeWeb.SampleChannel, "sample:lobby")

    %{socket: socket}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
