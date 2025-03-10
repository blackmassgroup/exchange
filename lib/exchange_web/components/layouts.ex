defmodule ExchangeWeb.Layouts do
  use ExchangeWeb, :html

  embed_templates "layouts/*"

  def toggle_mobile_menu() do
    JS.toggle(
      to: "#mobile-menu-canvas-backdrop",
      in: {"transition-opacity ease-linear duration-300", "opacity-0", "opacity-100"},
      out: {"transition-opacity ease-linear duration-300", "opacity-100", "opacity-0"}
    )
    |> JS.toggle(
      to: "#mobile-menu-fixed-insert",
      in: {"transition-opacity ease-linear duration-300", "opacity-0", "opacity-100"},
      out: {"transition-opacity ease-linear duration-300", "opacity-100", "opacity-0"}
    )
    |> JS.toggle(
      to: "#mobile-menu-canvas-menu-translate",
      in: {"transition ease-in-out duration-300 transform", "-translate-x-full", "translate-x-0"},
      out: {"transition ease-in-out duration-300 transform", "translate-x-0", "-translate-x-full"}
    )
    |> JS.toggle(
      to: "#mobile-menu-close",
      in: {"ease-in-out duration-300", "opacity-0", "opacity-100"},
      out: {"ease-in-out duration-300", "opacity-100", "opacity-0"}
    )
    |> JS.toggle(
      to: "#mobile-menu-canvas-menu",
      in: {"transition-opacity ease-linear duration-300", "opacity-0", "opacity-100"},
      out: {"transition-opacity ease-linear duration-300", "opacity-100", "opacity-0"}
    )
  end

  def nav_menu(assigns) do
    ~H"""
    <.mobile_menu_button current_user={@current_user} live_action={@live_action} />
    <.mobile_menu current_user={@current_user} live_action={@live_action} />
    <.desktop_menu current_user={@current_user} live_action={@live_action} />
    """
  end

  def mobile_menu_button(%{current_user: %{}, live_action: live_action} = assigns)
      when live_action != :index do
    ~H"""
    <div class="z-40 flex h-16 shrink-0 items-center gap-x-6 border-b border-white/5 bg-zinc-900 px-4 shadow-sm sm:px-6 lg:px-8 xl:hidden">
      <button
        type="button"
        class="-m-2.5 p-2.5 text-white xl:hidden"
        id="mobile-menu-toggle"
        phx-click={toggle_mobile_menu()}
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

  def mobile_menu_button(assigns), do: ~H{}

  def mobile_menu(assigns) do
    ~H"""
    <div
      id="mobile-menu-canvas-menu"
      class="relative z-50 hidden"
      role="dialog"
      aria-modal="true"
      style="display: none;"
    >
      <div id="mobile-menu-canvas-backdrop" class="fixed inset-0 bg-emerald-900/80"></div>

      <div id="mobile-menu-fixed-insert" class="fixed inset-0 flex">
        <div id="mobile-menu-canvas-menu-translate" class="relative mr-16 flex w-full max-w-xs flex-1">
          <div id="mobile-menu-close" class="absolute left-full top-0 flex w-16 justify-center pt-5">
            <button
              type="button"
              class="-m-2.5 p-2.5"
              id="mobile-menu-close-button"
              phx-click={toggle_mobile_menu()}
            >
              <span class="sr-only">Close sidebar</span>
              <svg
                class="h-6 w-6 text-white"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                aria-hidden="true"
              >
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          <div class="flex grow flex-col gap-y-5 overflow-y-auto bg-zinc-900 px-6 ring-1 ring-white/10 h-screen">
            <div class="flex-col h-16 shrink-0 items-center">
              <p class="rounded-full pt-4 text-[0.8125rem] text-xl font-semibold leading-6 text-emerald-500 mr-2">
                Virus.exchange
              </p>

              <p class="rounded-full pb-2 text-[0.6125rem] text-xl leading-6 text-emerald-500 mr-2">
                Powered by Vx Underground
              </p>

              <p class="rounded-full bg-emerald-900 px-2 text-[0.6125rem] font-medium leading-6 text-emerald-500">
                v {Application.spec(:exchange)[:vsn]}
              </p>
            </div>

            <hr class="border-zinc-700 mt-7" />

            <nav :if={@current_user} class="flex flex-1 flex-col">
              <ul role="list" class="flex flex-1 flex-col gap-y-7">
                <li>
                  <ul role="list" class="-mx-2 space-y-1">
                    <li class="-mx-6 mt-auto">
                      <div
                        href="#"
                        class="flex items-center gap-x-4 px-6 py-3 text-sm font-medium leading-6 text-white"
                      >
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke-width="1.5"
                          stroke="currentColor"
                          class="w-6 h-6 text-emerald-500"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            d="M17.982 18.725A7.488 7.488 0 0012 15.75a7.488 7.488 0 00-5.982 2.975m11.963 0a9 9 0 10-11.963 0m11.963 0A8.966 8.966 0 0112 21a8.966 8.966 0 01-5.982-2.275M15 9.75a3 3 0 11-6 0 3 3 0 016 0z"
                          />
                        </svg>

                        <span class="sr-only">Your profile</span>
                        <span :if={@current_user} aria-hidden="true" class="text-emerald-500">
                          {@current_user.email}
                        </span>
                      </div>
                    </li>
                    <li>
                      <!-- Current: "bg-gray-800 text-white", Default: "text-gray-400 hover:text-white hover:bg-zinc-800" -->
                      <.link
                        navigate={~p"/samples"}
                        class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                      >
                        <svg
                          class="h-6 w-6 shrink-0"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke-width="1.5"
                          stroke="currentColor"
                          aria-hidden="true"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            d="M2.25 12.75V12A2.25 2.25 0 014.5 9.75h15A2.25 2.25 0 0121.75 12v.75m-8.69-6.44l-2.12-2.12a1.5 1.5 0 00-1.061-.44H4.5A2.25 2.25 0 002.25 6v12a2.25 2.25 0 002.25 2.25h15A2.25 2.25 0 0021.75 18V9a2.25 2.25 0 00-2.25-2.25h-5.379a1.5 1.5 0 01-1.06-.44z"
                          />
                        </svg>
                        Samples
                      </.link>
                    </li>
                    <li>
                      <.link
                        navigate={~p"/users/settings"}
                        class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                      >
                        <svg
                          class="h-6 w-6 shrink-0"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke-width="1.5"
                          stroke="currentColor"
                          aria-hidden="true"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 011.37.49l1.296 2.247a1.125 1.125 0 01-.26 1.431l-1.003.827c-.293.24-.438.613-.431.992a6.759 6.759 0 010 .255c-.007.378.138.75.43.99l1.005.828c.424.35.534.954.26 1.43l-1.298 2.247a1.125 1.125 0 01-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.57 6.57 0 01-.22.128c-.331.183-.581.495-.644.869l-.213 1.28c-.09.543-.56.941-1.11.941h-2.594c-.55 0-1.02-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 01-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 01-1.369-.49l-1.297-2.247a1.125 1.125 0 01.26-1.431l1.004-.827c.292-.24.437-.613.43-.992a6.932 6.932 0 010-.255c.007-.378-.138-.75-.43-.99l-1.004-.828a1.125 1.125 0 01-.26-1.43l1.297-2.247a1.125 1.125 0 011.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.087.22-.128.332-.183.582-.495.644-.869l.214-1.281z"
                          />
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                          />
                        </svg>
                        Settings
                      </.link>
                    </li>

                    <%= if @current_user.role.name ==  "Admin" do %>
                      <.link
                        href={~p"/manage/users"}
                        class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                      >
                        <svg
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke-width="1.5"
                          stroke="currentColor"
                          class="w-6 h-6"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z"
                          />
                        </svg>
                        Users
                      </.link>
                      <.link
                        href={~p"/roles"}
                        class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                      >
                        <svg
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke-width="1.5"
                          stroke="currentColor"
                          class="w-6 h-6"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z"
                          />
                        </svg>
                        Roles
                      </.link>

                      <.link
                        href={~p"/errors"}
                        class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                      >
                        🐛
                        Error Tracker
                      </.link>

                      <.link
                        href={~p"/dashboard"}
                        class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                      >
                        💻 Dashboard
                      </.link>

                      <.link
                        href={~p"/oban"}
                        class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                      >
                        Oban Dashboard
                      </.link>
                    <% end %>
                    <li>
                      <.link
                        href={~p"/users/log_out"}
                        class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                      >
                        <svg
                          class="h-6 w-6 shrink-0"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke-width="1.5"
                          stroke="currentColor"
                          aria-hidden="true"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15M12 9l-3 3m0 0l3 3m-3-3h12.75"
                          />
                        </svg>
                        Log out
                      </.link>
                    </li>
                  </ul>
                </li>
                <li :if={@current_user} class="-mx-6 mt-auto">
                  <div
                    href="#"
                    class="flex items-center gap-x-4 px-6 py-3 text-sm font-medium leading-6 text-white"
                  >
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      class="w-6 h-6 text-emerald-500"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M17.982 18.725A7.488 7.488 0 0012 15.75a7.488 7.488 0 00-5.982 2.975m11.963 0a9 9 0 10-11.963 0m11.963 0A8.966 8.966 0 0112 21a8.966 8.966 0 01-5.982-2.275M15 9.75a3 3 0 11-6 0 3 3 0 016 0z"
                      />
                    </svg>

                    <span class="sr-only">Your profile</span>
                    <span :if={@current_user} aria-hidden="true" class="text-emerald-500">
                      {@current_user.email}
                    </span>
                  </div>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def desktop_menu(%{current_user: cur_user} = assigns) when cur_user != nil do
    ~H"""
    <div class="hidden xl:fixed xl:inset-y-0 xl:z-50 xl:flex xl:w-72 xl:flex-col">
      <!-- Sidebar component, swap this element with another sidebar if you like -->
      <div class="flex grow flex-col gap-y-5 overflow-y-auto bg-black/10 px-6 pt-3 ring-1 ring-white/5">
        <div class="flex h-16 shrink-0 flex-col justify-around">
          <p class="rounded-full pt-2 text-[0.8125rem] text-xl font-semibold leading-6 text-zinc-300 mr-2">
            Virus.exchange
          </p>

          <p class="rounded-full pb-2 text-[0.6125rem] text-xl leading-6 text-zinc-300 mr-2">
            Powered by Vx Underground
          </p>
          <p class="rounded-full bg-emerald-900 px-2 text-[0.6125rem] font-medium leading-6 text-zinc-300">
            v {Application.spec(:exchange)[:vsn]}
          </p>
        </div>
        <nav class="flex flex-1 flex-col">
          <ul role="list" class="flex flex-1 flex-col gap-y-7">
            <li>
              <ul role="list" class="-mx-2 space-y-1">
                <li>
                  <!-- Current: "bg-gray-800 text-white", Default: "text-gray-400 hover:text-white hover:bg-zinc-800" -->
                  <.link
                    href={~p"/samples"}
                    class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                  >
                    <svg
                      class="h-6 w-6 shrink-0"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M2.25 12.75V12A2.25 2.25 0 014.5 9.75h15A2.25 2.25 0 0121.75 12v.75m-8.69-6.44l-2.12-2.12a1.5 1.5 0 00-1.061-.44H4.5A2.25 2.25 0 002.25 6v12a2.25 2.25 0 002.25 2.25h15A2.25 2.25 0 0021.75 18V9a2.25 2.25 0 00-2.25-2.25h-5.379a1.5 1.5 0 01-1.06-.44z"
                      />
                    </svg>
                    Samples
                  </.link>
                </li>
                <%= if @current_user.role.name ==  "Admin" do %>
                  <.link
                    href={~p"/manage/users"}
                    class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                  >
                    <svg
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      class="w-6 h-6"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z"
                      />
                    </svg>
                    Users
                  </.link>
                  <.link
                    href={~p"/roles"}
                    class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                  >
                    <svg
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      class="w-6 h-6"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z"
                      />
                    </svg>
                    Roles
                  </.link>
                  <.link
                    href={~p"/errors"}
                    class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                  >
                    🐛
                    Error Tracker
                  </.link>
                  <.link
                    href={~p"/dashboard"}
                    class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                  >
                    💻 Dashboard
                  </.link>
                <% end %>
                <li>
                  <.link
                    href={~p"/users/settings"}
                    class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                  >
                    <svg
                      class="h-6 w-6 shrink-0"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 011.37.49l1.296 2.247a1.125 1.125 0 01-.26 1.431l-1.003.827c-.293.24-.438.613-.431.992a6.759 6.759 0 010 .255c-.007.378.138.75.43.99l1.005.828c.424.35.534.954.26 1.43l-1.298 2.247a1.125 1.125 0 01-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.57 6.57 0 01-.22.128c-.331.183-.581.495-.644.869l-.213 1.28c-.09.543-.56.941-1.11.941h-2.594c-.55 0-1.02-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 01-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 01-1.369-.49l-1.297-2.247a1.125 1.125 0 01.26-1.431l1.004-.827c.292-.24.437-.613.43-.992a6.932 6.932 0 010-.255c.007-.378-.138-.75-.43-.99l-1.004-.828a1.125 1.125 0 01-.26-1.43l1.297-2.247a1.125 1.125 0 011.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.087.22-.128.332-.183.582-.495.644-.869l.214-1.281z"
                      />
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                      />
                    </svg>
                    Settings
                  </.link>
                </li>
                <li class="mt-auto">
                  <hr class="py-3 mt-3 border-zinc-700" />
                  <div
                    href="#"
                    class="flex items-center gap-x-4 px-2 py-3 text-sm font-medium leading-6 text-white"
                  >
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      class="w-6 h-6 text-zinc-500"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M17.982 18.725A7.488 7.488 0 0012 15.75a7.488 7.488 0 00-5.982 2.975m11.963 0a9 9 0 10-11.963 0m11.963 0A8.966 8.966 0 0112 21a8.966 8.966 0 01-5.982-2.275M15 9.75a3 3 0 11-6 0 3 3 0 016 0z"
                      />
                    </svg>

                    <span class="sr-only">Your profile</span>
                    <span :if={@current_user} aria-hidden="true" class="text-zinc-500">
                      {@current_user.email}
                    </span>
                  </div>
                </li>
                <li>
                  <.link
                    href={~p"/users/log_out"}
                    class="text-gray-400 hover:text-white hover:bg-zinc-800 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
                  >
                    <svg
                      class="h-6 w-6 shrink-0"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15M12 9l-3 3m0 0l3 3m-3-3h12.75"
                      />
                    </svg>
                    Log out
                  </.link>
                </li>
              </ul>
            </li>
          </ul>
        </nav>
      </div>
    </div>
    """
  end

  def desktop_menu(assigns), do: ~H{}

  def loading_component(assigns) do
    ~H"""
    <div
      :if={not Phoenix.LiveView.connected?(@socket) and @samples == []}
      class="p-6 m-6 animate-pulse"
    >
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
    </div>
    """
  end
end
