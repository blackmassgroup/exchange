defmodule VxUndergroundWeb.UserSettingsLive do
  use VxUndergroundWeb, :live_view

  alias VxUnderground.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-prose bg-slate-50 p-6 mb-5 dark:bg-zinc-800 dark:bg-zinc-800  dark:text-slate-200">
      <.header>
        <strong>User Role:</strong> <%= if @current_user.role != nil,
          do: @current_user.role.name,
          else: "No role." %>
      </.header>

      <br />
      <strong>Custom Permissions: </strong>
      <%= if @current_user.custom_permissions not in [nil, %{}],
        do: Jason.encode!(@current_user.custom_permissions),
        else: "No custom permissions." %>
    </div>

    <div
      :if={@current_user.role && @current_user.role.name == "Admin"}
      class="mx-auto max-w-prose bg-slate-50 p-6 mb-5 dark:bg-zinc-800 dark:bg-zinc-800  dark:text-slate-200"
    >
      <.header>
        <strong>Api Key:</strong>
        <p class="text-sm mb-2">
          <small>
            This is your API key. You can use it to access the API. Please keep it safe.
          </small>
        </p>

        <p class="text-xs">
          Make a POST request to virus.exchange/upload with your API key in the Authorization header.
          The body should have one key, "file", with the value being the binary you want to upload.
        </p>

        <div>
          <label for="email" class="block text-sm font-medium leading-6 text-gray-900"></label>
          <div class="mt-2 flex rounded-md shadow-sm">
            <div class="relative flex flex-grow items-stretch focus-within:z-10">
              <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
                <svg
                  class="h-3 w-4 text-gray-400"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                  aria-hidden="true"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M15.75 5.25a3 3 0 013 3m3 0a6 6 0 01-7.029 5.912c-.563-.097-1.159.026-1.563.43L10.5 17.25H8.25v2.25H6v2.25H2.25v-2.818c0-.597.237-1.17.659-1.591l6.499-6.499c.404-.404.527-1 .43-1.563A6 6 0 1121.75 8.25z"
                  />
                </svg>
              </div>
              <input
                type={@type}
                id="api_key"
                disabled
                value={if @type == "text", do: @current_user.api_key, else: "**************"}
                class="block w-full rounded-none rounded-l-md border-0 py-1.5 pl-10 text-gray-900 ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
              />
            </div>
            <button
              type="button"
              class="relative -ml-px inline-flex items-center gap-x-1.5 rounded-r-md px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
              phx-click="toggle-type"
            >
              <svg
                :if={@type == "password"}
                class="mb-0.5 mr-0.5 h-3 w-4 text-gray-400"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178z"
                />
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                />
              </svg>

              <svg
                :if={@type == "text"}
                class="mb-0.5 mr-0.5 h-3 w-4 text-gray-400"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88"
                />
              </svg>
            </button>
          </div>
        </div>
      </.header>
    </div>
    <div class="mx-auto max-w-prose bg-slate-50 p-6 mb-5  dark:bg-zinc-800">
      <.header>Change Email</.header>

      <.simple_form
        :let={f}
        id="email_form"
        for={@email_changeset}
        phx-submit="update_email"
        phx-change="validate_email"
      >
        <.error :if={@email_changeset.action == :insert}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={{f, :email}} type="email" label="Email" required />

        <.input
          field={{f, :current_password}}
          name="current_password"
          id="current_password_for_email"
          type="password"
          label="Current password"
          value={@email_form_current_password}
          required
        />
        <:actions>
          <.button phx-disable-with="Changing...">Change Email</.button>
        </:actions>
      </.simple_form>
    </div>

    <div class="mx-auto max-w-prose bg-slate-50 p-6 mb-5  dark:bg-zinc-800">
      <.header>Change Password</.header>

      <.simple_form
        :let={f}
        id="password_form"
        for={@password_changeset}
        action={~p"/users/log_in?_action=password_updated"}
        method="post"
        phx-change="validate_password"
        phx-submit="update_password"
        phx-trigger-action={@trigger_submit}
      >
        <.error :if={@password_changeset.action == :insert}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={{f, :email}} type="hidden" value={@current_email} />

        <.input field={{f, :password}} type="password" label="New password" required />
        <.input field={{f, :password_confirmation}} type="password" label="Confirm new password" />
        <.input
          field={{f, :current_password}}
          name="current_password"
          type="password"
          label="Current password"
          id="current_password_for_password"
          value={@current_password}
          required
        />
        <:actions>
          <.button phx-disable-with="Changing...">Change Password</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_changeset, Accounts.change_user_email(user))
      |> assign(:password_changeset, Accounts.change_user_password(user))
      |> assign(:trigger_submit, false)
      |> assign(:type, "password")

    {:ok, socket}
  end

  def handle_event("toggle-type", _param, socket) do
    socket =
      case socket.assigns.type do
        "password" -> assign(socket, :type, "text")
        "text" -> assign(socket, :type, "password")
      end

    {:noreply, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    email_changeset = Accounts.change_user_email(socket.assigns.current_user, user_params)

    socket =
      assign(socket,
        email_changeset: Map.put(email_changeset, :action, :validate),
        email_form_current_password: password
      )

    {:noreply, socket}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, put_flash(socket, :info, info)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_changeset, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    password_changeset = Accounts.change_user_password(socket.assigns.current_user, user_params)

    {:noreply,
     socket
     |> assign(:password_changeset, Map.put(password_changeset, :action, :validate))
     |> assign(:current_password, password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        socket =
          socket
          |> assign(:trigger_submit, true)
          |> assign(:password_changeset, Accounts.change_user_password(user, user_params))

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :password_changeset, changeset)}
    end
  end
end
