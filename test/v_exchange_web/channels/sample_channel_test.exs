defmodule VExchangeWeb.SampleChannelTest do
  use VExchangeWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      VExchangeWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(VExchangeWeb.SampleChannel, "sample:lobby")

    %{socket: socket}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
