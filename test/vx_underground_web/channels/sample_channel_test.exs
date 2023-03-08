defmodule VxUndergroundWeb.SampleChannelTest do
  use VxUndergroundWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      VxUndergroundWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(VxUndergroundWeb.SampleChannel, "sample:lobby")

    %{socket: socket}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
