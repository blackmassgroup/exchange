defmodule VExchangeWeb.SampleLive.Index do
  use VExchangeWeb, :live_view
  use Timex

  alias VExchange.Services.S3
  alias VExchange.Samples
  alias VExchange.Sample
  alias Phoenix.LiveView.AsyncResult

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(VExchange.PubSub, "samples")
    end

    socket =
      socket
      |> assign(:search, "")
      |> assign(:samples, AsyncResult.loading())
      |> start_async(:samples, fn -> Samples.list_samples(%{order: :desc, limit: 20}) end)
      |> assign(:count, AsyncResult.loading())
      |> start_async(:count, fn -> Samples.get_sample_count!() end)

    {:ok, socket}
  end

  @impl true
  def handle_async(assign_key, {:ok, results}, socket) do
    async_result = Map.get(socket.assigns, assign_key)
    {:noreply, assign(socket, assign_key, AsyncResult.ok(async_result, results))}
  end

  def handle_async(assign_key, {:exit, reason}, socket) do
    async_result = Map.get(socket.assigns, assign_key)
    {:noreply, assign(socket, assign_key, AsyncResult.failed(async_result, {:exit, reason}))}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Sample")
    |> assign(:sample, Samples.get_sample!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Sample")
    |> assign(:sample, %Sample{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Samples")
    |> assign(:sample, nil)
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Show Sample")
    |> assign(:sample, Samples.get_sample!(id))
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    sample = Samples.get_sample!(id)
    {:ok, _} = Samples.delete_sample(sample)
    samples = socket.assigns.samples
    new_samples = samples.result |> Enum.reject(&(&1.id == sample.id))
    {:noreply, assign(socket, :samples, AsyncResult.ok(samples, new_samples))}
  end

  def handle_event("search", %{"search" => hashes}, socket)
      when byte_size(hashes) in [0, 32, 40, 64, 128] do
    socket =
      socket
      |> assign(:samples, AsyncResult.loading())
      |> start_async(:samples, fn -> Samples.list_samples(%{hash: hashes}) end)
      |> assign(:search, hashes)

    {:noreply, socket}
  end

  def handle_event("search", %{"search" => hashes}, socket) do
    samples = socket.assigns.samples

    socket =
      socket
      |> assign(:samples, AsyncResult.ok(samples, []))
      |> assign(:search, hashes)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_sample, new_sample}, socket) do
    if socket.assigns.search == "" and socket.assigns.samples.loading == false do
      current_samples = socket.assigns.samples
      current_count = socket.assigns.count
      new_samples = [new_sample | current_samples.result || []]

      samples = AsyncResult.ok(current_samples, new_samples)
      count = AsyncResult.ok(current_count, (current_count.result || 0) + 1)

      socket =
        assign(socket, :samples, samples)
        |> assign(:count, count)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:deleted_sample, new_sample}, socket) do
    if socket.assigns.search == "" and socket.assigns.samples.loading == false do
      current_samples = socket.assigns.samples
      current_count = socket.assigns.count
      new_samples = Enum.reject(current_samples.result || [], &(&1.sha256 == new_sample.sha256))

      samples = AsyncResult.ok(current_samples, new_samples)
      count = AsyncResult.ok(current_count, (current_count.result || 0) - 1)

      socket =
        assign(socket, :samples, samples)
        |> assign(:count, count)

      socket =
        if new_sample.user_id == socket.assigns.current_user.id do
          socket
          |> put_flash(:warning, "Non-Malware Sample deleted")
        else
          socket
        end

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:updated_sample, new_sample}, socket) do
    if socket.assigns.search == "" and socket.assigns.samples.loading == false do
      current_samples = socket.assigns.samples
      current_count = socket.assigns.count

      new_samples =
        Enum.map(current_samples.result || [], fn sample ->
          if sample.sha256 == new_sample.sha256 do
            new_sample
          else
            sample
          end
        end)

      samples = AsyncResult.ok(current_samples, new_samples)
      count = AsyncResult.ok(current_count, (current_count.result || 0) - 1)

      socket =
        assign(socket, :samples, samples)
        |> assign(:count, count)

      socket =
        if new_sample.user_id == socket.assigns.current_user.id do
          socket
          |> put_flash(:warning, "Non-Malware Sample deleted")
        else
          socket
        end

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def format_time(past_datetime) do
    current_datetime = NaiveDateTime.utc_now()

    NaiveDateTime.diff(current_datetime, past_datetime)
    |> Elixir.Timex.Duration.from_seconds()
    |> Elixir.Timex.Format.Duration.Formatters.Humanized.format()
    |> String.split(",")
    |> Enum.take(3)
    |> Enum.join(",")
    |> then(&(&1 <> " ago"))
  end

  # View functions

  def generate_url_for_file(s3_object_key) do
    opts = [expires_in: 300]
    bucket = S3.get_wasabi_bucket()
    config_opts = S3.wasabi_config()

    ExAws.Config.new(:s3, config_opts)
    |> ExAws.S3.presigned_url(:get, bucket, s3_object_key, opts)
    |> case do
      {:ok, url} -> url
      _ -> "#"
    end
  end

  def get_shown_number(nil, _), do: 0

  def get_shown_number(size, :KB), do: size

  def get_shown_number(size, :MB), do: size / (1024 * 1024)

  def get_shown_number(size, :GB), do: size / (1024 * 1024 * 1024)

  def search_header(%{mobile_menu_only: true} = assigns) do
    ~H"""
    <div class="sticky top-0 z-40 flex h-16 shrink-0 items-center gap-x-6 border-b border-white/5 bg-zinc-900 px-4 shadow-sm sm:px-6 lg:px-8">
      <button
        type="button"
        class="-m-2.5 p-2.5 text-white xl:hidden"
        id="home-page-mobile-menu-toggle"
        phx-click={VExchangeWeb.Layouts.toggle_mobile_menu()}
      >
        <span class="sr-only">Open sidebar</span>
        <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path
            fill-rule="evenodd"
            d="M2 4.75A.75.75 0 012.75 4h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 4.75zM2 10a.75.75 0 01.75-.75h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 10zm0 5.25a.75.75 0 01.75-.75h14.5a.75.75 0 010 1.5H2.75a.75.75 0 01-.75-.75z"
            clip-rule="evenodd"
          />
        </svg>
      </button>
    </div>
    """
  end

  def search_header(assigns) do
    ~H"""
    <div class="sticky top-0 z-40 flex h-16 shrink-0 items-center gap-x-6 border-b border-white/5 bg-zinc-900 px-4 shadow-sm sm:px-6 lg:px-8">
      <button
        type="button"
        class="-m-2.5 p-2.5 text-white xl:hidden"
        id="home-page-mobile-menu-toggle"
        phx-click={VExchangeWeb.Layouts.toggle_mobile_menu()}
      >
        <span class="sr-only">Open sidebar</span>
        <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path
            fill-rule="evenodd"
            d="M2 4.75A.75.75 0 012.75 4h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 4.75zM2 10a.75.75 0 01.75-.75h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 10zm0 5.25a.75.75 0 01.75-.75h14.5a.75.75 0 010 1.5H2.75a.75.75 0 01-.75-.75z"
            clip-rule="evenodd"
          />
        </svg>
      </button>

      <div class="flex flex-1 gap-x-4 self-stretch lg:gap-x-6">
        <form class="flex flex-1" phx-change="search" id="search">
          <label for="search-field" class="sr-only">Search by md5, sha1, sha256 or sha512</label>
          <div class="relative w-full">
            <svg
              class="pointer-events-none absolute inset-y-0 left-0 h-full w-5 text-gray-500"
              viewBox="0 0 20 20"
              fill="currentColor"
              aria-hidden="true"
            >
              <path
                fill-rule="evenodd"
                d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z"
                clip-rule="evenodd"
              />
            </svg>

            <input
              id="hashes-input"
              name="search"
              value={@search}
              phx-value={@search}
              errors={[]}
              class="block h-full w-full border-0 bg-transparent py-0 pl-8 pr-0 text-white focus:ring-0 sm:text-sm"
              placeholder="Search by md5, sha1, sha256 or sha512..."
              type="text"
            />
          </div>
        </form>
      </div>
    </div>
    """
  end

  def main_sample_list(assigns) do
    ~H"""
    <div id="main-stream-parent">
      <.async_result :let={samples} assign={@samples}>
        <:loading><span class="text-slate-600 p-8">Loading samples...</span></:loading>
        <:failed :let={_failure}>
          <span class="text-emerald-600 p-8">there was an error loading the samples</span>
        </:failed>
        <ul role="list" class="divide-y divide-white/5" id="main-stream-parent">
          <li
            :for={sample <- samples}
            class="relative flex items-center space-x-4 px-4 py-4 sm:px-6 lg:px-8 hover:bg-emerald-900"
            id={"msl-#{sample.id}"}
          >
            <div class="min-w-0 flex-auto">
              <div class="flex items-center gap-x-3">
                <div class="flex-none rounded-full p-1 text-gray-500 bg-gray-100/10">
                  <div class="h-2 w-2 rounded-full bg-current"></div>
                </div>
                <h2 class="min-w-0 text-sm font-semibold leading-6 text-white">
                  <.link navigate={~p"/samples/#{sample.id}"} class="flex gap-x-2">
                    <span><strong>SHA256</strong></span>

                    <span class="text-gray-400">/</span>
                    <span class="whitespace-nowrap">
                      <%= sample.sha256 || "New Upload.. Still Processing" %>
                    </span>
                  </.link>
                </h2>
              </div>
              <div class="mt-3 flex items-center gap-x-2.5 text-xs leading-5 text-gray-400">
                <div>
                  <p class="">
                    <%= if sample.md5 do %>
                      <strong>MD5:</strong> <%= sample.md5 %> <br />
                      <strong>SHA1:</strong> <%= sample.sha1 %>
                    <% else %>
                      Processing...
                    <% end %>
                  </p>
                  <p class="whitespace-nowrap">
                    <strong>FILE SIZE: </strong>
                    <%= get_shown_number(sample.size, :KB)
                    |> Number.Delimit.number_to_delimited(precision: 0) %> KB / <%= get_shown_number(
                      sample.size,
                      :MB
                    )
                    |> Number.Delimit.number_to_delimited(precision: 2) %> MB / <%= get_shown_number(
                      sample.size,
                      :GB
                    )
                    |> Number.Delimit.number_to_delimited(precision: 4) %> GB
                  </p>
                </div>
                <div :if={sample.tags} class="flex max-w-xs flex-wrap">
                  <span
                    :for={tag <- sample.tags |> Enum.take(3)}
                    class="truncate rounded-full bg-emerald-900 px-2 text-[0.8125rem] font-medium leading-6 text-emerald-500 mb-2"
                  >
                    <%= tag %>
                  </span>
                </div>
              </div>
              <time datetime={sample.inserted_at} class="flex-none text-xs text-gray-400">
                Uploaded: <%= format_time(sample.inserted_at) %>
              </time>
            </div>

            <.link
              href={generate_url_for_file(sample.sha256)}
              download={generate_url_for_file(sample.sha256)}
              target="_blank"
              class="rounded-full flex-none py-1 px-2 text-xs font-medium ring-1 ring-inset text-gray-400 bg-gray-400/10 ring-gray-400/20 hover:bg-zinc-800 hover:text-white hover:border-zinc-900"
            >
              Download
            </.link>
            <.link
              :if={@current_user.role && @current_user.role.name == "Admin"}
              phx-click={JS.push("delete", value: %{id: sample.id})}
              data-confirm="Are you sure?"
              class="rounded-full flex-none py-1 px-2 text-xs font-medium ring-1 ring-inset text-gray-400 bg-gray-400/10 ring-gray-400/20 hover:bg-zinc-800 hover:text-white hover:border-zinc-900"
            >
              Delete
            </.link>
            <.link navigate={~p"/samples/#{sample.id}"} class="flex gap-x-2">
              <svg
                class="h-5 w-5 flex-none text-gray-400"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  fill-rule="evenodd"
                  d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z"
                  clip-rule="evenodd"
                />
              </svg>
            </.link>
          </li>
        </ul>
      </.async_result>
    </div>
    """
  end

  def activity_feed(assigns) do
    ~H"""
    <div id="as-stream-container">
      <.async_result :let={samples} assign={@samples}>
        <:loading><span class="text-slate-600 p-8">Loading samples...</span></:loading>
        <:failed :let={_failure}>
          <span class="text-emerald-600 p-8">there was an error loading the samples</span>
        </:failed>

        <ul role="list" class="divide-y divide-white/5" id="as-stream-container">
          <li
            :for={sample <- samples}
            class="px-4 py-4 sm:px-6 lg:px-8 hover:bg-emerald-900 text-gray-600 hover:text-gray-300"
            id={"#{sample.id}"}
          >
            <.link navigate={~p"/samples/#{sample.id}"}>
              <div class="flex items-center gap-x-3">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="#aaa"
                  class="w-6 h-6 text-zinc-700"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m6.75 12l-3-3m0 0l-3 3m3-3v6m-1.5-15H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z"
                  />
                </svg>

                <time datetime={sample.inserted_at} class="flex-none text-xs">
                  <%= format_time(sample.inserted_at) %>
                </time>
              </div>
              <p class="mt-3 truncate text-sm text-gray-500">
                <span class="text-gray-400 hover:text-gray:400">SHA256</span>
                (<span class="font-mono text-gray-400  hover:text-gray:400 truncate"><%= sample.sha256 %></span> on <span class="text-gray-400"></span>)
              </p>
            </.link>
          </li>
        </ul>
      </.async_result>
    </div>
    """
  end
end
