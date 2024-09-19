defmodule Exchange.VtApi.VtApiRateLimiter do
  @moduledoc """
  A module responsible for rate limiting VT API requests.

  This module uses `GenServer` to define a process that maintains a counter for each priority level.
  The counters are incremented when a request is allowed, and the total count is incremented when a request is made.
  The module also provides a way to get statistics about current usage.

  Example usage:
  ```
  {:ok, vt_api_rate_limiter} = Exchange.VtApiRateLimiter.start_link(1700)
  Exchange.VtApiRateLimiter.allow_request(vt_api_rate_limiter, 0)
  Exchange.VtApiRateLimiter.allow_request(vt_api_rate_limiter, 1)
  Exchange.VtApiRateLimiter.allow_request(vt_api_rate_limiter, 2)
  Exchange.VtApiRateLimiter.allow_request(vt_api_rate_limiter, 3)
  ```
  """
  use GenServer
  require Logger

  @default_interval :timer.minutes(1)

  @impl true
  def init(init_arg) do
    schedule_reset()
    {:ok, init_arg}
  end

  @doc """
  Starts the VT API rate limiter process.

  ## Parameters
    - `initial_limit`: The initial limit for the rate limiter.

  ## Returns
    - The PID of the started process.
  """
  def start_link(initial_limit) do
    GenServer.start_link(
      __MODULE__,
      %{
        limit: initial_limit,
        counts: %{0 => 0, 1 => 0, 2 => 0, 3 => 0},
        total_count: 0
      },
      name: __MODULE__
    )
  end

  @impl true
  def handle_call({:allow_request, priority}, _from, state) do
    if state.total_count < state.limit do
      new_counts = Map.update!(state.counts, priority, &(&1 + 1))
      new_state = %{state | counts: new_counts, total_count: state.total_count + 1}
      {:reply, :ok, new_state}
    else
      Logger.warning("Rate limit reached: #{state.total_count}/#{state.limit}")
      {:reply, {:rate_limited, priority}, state}
    end
  end

  @impl true
  def handle_call(:get_stats, _from, state) do
    {:reply, {state.counts, state.total_count, state.limit}, state}
  end

  @impl true
  def handle_call({:get_snooze_time, priority}, _from, state) do
    {:reply, get_snooze(priority), state}
  end

  @impl true
  def handle_info(:reset, state) do
    schedule_reset()
    {:noreply, %{state | counts: %{0 => 0, 1 => 0, 2 => 0, 3 => 0}, total_count: 0}}
  end

  @impl true
  def handle_cast({:set_limit, new_limit}, state) do
    {:noreply, %{state | limit: new_limit}}
  end

  @doc """
  Checks if a request is allowed based total count, priority is only logged.
  """
  def allow_request(priority) do
    GenServer.call(__MODULE__, {:allow_request, priority})
  end

  @doc """
  Sets the limit for the rate limiter.
  """
  def set_limit(new_limit) do
    GenServer.cast(__MODULE__, {:set_limit, new_limit})
  end

  @doc """
  Returns the current statistics of the rate limiter.
  """
  def get_stats do
    GenServer.call(__MODULE__, :get_stats)
  end

  def get_snooze_time(priority) do
    GenServer.call(__MODULE__, {:get_snooze_time, priority})
  end

  # Schedules a reset of the counters.
  defp schedule_reset do
    Process.send_after(self(), :reset, @default_interval)
  end

  # Returns the snooze time for a given priority.
  defp get_snooze(priority) do
    case priority do
      0 -> 15
      1 -> 30
      2 -> 45
      3 -> 60
    end
  end
end
