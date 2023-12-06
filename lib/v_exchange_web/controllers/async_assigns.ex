defmodule VExchangeWeb.AsyncAssigns do
  import Phoenix.Socket, only: [assign: 2, assign: 3]

  @doc """
  Provides ability to assign default values to the socket, and kick off a
  process that will send a message to the LiveView.  The message payload will
  be assigned as specified.
  ## Usage
  Add the following lines to a specific LiveView, or to the web module
  function 'live_view/1` so they will be used in every LiveView.

  ## Examples
  Assign :loading to the :todo_list assign for the current mount call.  Spawn
  a process that will run the `supplier` function.  When the function
  completes, a message will be sent back to the LiveView, which will assign the
  list returned to the :todo_list assign.
  If an error occurs, the :todo_list assign will be set to :error.
  ```elixir
  def mount(params, session, socket) do
    socket = async_assign(
      socket,
      key: :news_list,
      default: {:loading, loading_stub()},
      on_error: {:error, error_stub()},
      supplier: fn socket ->
        News.current_events(socket.assigns.current_user.profile)
      end
    )
    {:ok, socket}
  end
  ```
  ## Opts
  * supplier (required, no default) - function that will be run in a spawned
      process, and send results back to parent process. Function has one
      argument, which is the socket.  This can be used however the user would
      like for reference, but the function should not modify, and return the socket.

  * key - (default nil) - If defined, the `default` value will be assigned
      immediately to the socket. The result of the `supplier` function will be
      assigned to this value when it completes.

  * default - (default nil) - If defined, this value will be assigned to the
      `key` value of the socket within the current process.

  * defaults - (default nil) - If defined, this keyword list will be assigned
      to the socket within the current process.

  * link - (default false) - If true, the spawned process will be linked to the
      LiveView process. If an error is raised, the LiveView will crash as the
      error will be re-raised.  If on_error is specified, the error will not be
      re-raised, and the on_error value will be assigned.  Therefore it doesn't
      make sense to use link if on_error is specified.

  * on_error - (default nil) - If not provided, any error produced by
      `supplier` will be reraised. If `on_error` is provided, it will be
      assigned under the `key` value if specified.  If `key` is not specified, a keyword list of
      assigns is expected.
  """
  @spec async_assign(
          socket :: Socket.t(),
          opts :: [
            supplier: (Socket.t() -> {:assigns, any()} | any()),
            key: atom(),
            default: any(),
            defaults: Keyword.t(),
            link: boolean(),
            on: [atom()]
          ]
        ) :: Socket.t()
  def async_assign(socket, opts \\ []) do
    socket = async_assign_defaults(socket, opts)

    if Phoenix.LiveView.connected?(socket) do
      async_assign_spawn(socket, opts)
    end

    socket
  end

  defp async_assign_defaults(socket, opts) do
    socket =
      case Keyword.get(opts, :default) do
        nil -> socket
        default -> assign(socket, Keyword.fetch!(opts, :key), default)
      end

    socket =
      case Keyword.get(opts, :defaults) do
        nil -> socket
        defaults -> assign(socket, defaults)
      end

    socket
  end

  defp async_assign_spawn(socket, opts) do
    parent = self()
    supplier = Keyword.fetch!(opts, :supplier)

    invoke_and_send = fn ->
      try do
        result = supplier.(socket)

        to_send =
          case Keyword.get(opts, :key) do
            nil ->
              {:async_assign, result}

            key ->
              {:async_assign, [{key, result}]}
          end

        send(parent, to_send)
      rescue
        e ->
          case Keyword.get(opts, :on_error) do
            nil ->
              reraise(e, __STACKTRACE__)

            on_error ->
              assign_error =
                case Keyword.get(opts, :key) do
                  nil ->
                    on_error

                  key ->
                    [{key, on_error}]
                end

              send(parent, {:async_assign, assign_error})
          end
      end
    end

    if Keyword.get(opts, :link) do
      spawn_link(invoke_and_send)
    else
      spawn(invoke_and_send)
    end
  end

  defmacro __using__(_opts) do
    quote do
      @impl true
      def handle_info({:async_assign, assigns}, socket) do
        {:noreply, assign(socket, assigns)}
      end
    end
  end
end
