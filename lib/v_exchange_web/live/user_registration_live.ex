defmodule VExchangeWeb.UserRegistrationLive do
  use VExchangeWeb, :live_view

  alias VExchange.Accounts
  alias VExchange.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center h-screen">
      <div class="mx-auto max-w-sm">
        <.header class="text-center text-white">
          <span class="text-white">Register for an virus.exchange account</span>
          <:subtitle>
            Already registered?
            <.link navigate={~p"/users/log_in"} class="font-semibold text-emerald-500 hover:underline">
              Sign in
            </.link>
            to your account now.
          </:subtitle>
        </.header>

        <.simple_form
          :let={f}
          id="registration_form"
          for={@changeset}
          phx-submit="save"
          phx-change="validate"
          phx-trigger-action={@trigger_submit}
          action={~p"/users/log_in?_action=registered"}
          method="post"
          as={:user}
        >
          <.error :if={@changeset.action == :insert}>
            Oops, something went wrong! Please check the errors below.
          </.error>

          <.input field={{f, :email}} type="email" label="Email" required />
          <.input field={{f, :password}} type="password" label="Password" required />
          <.input
            :if={@checked == true}
            field={{f, :malcore}}
            type="checkbox"
            phx-click="toggle-checkbox"
            label="Create Malcore Account?"
            checked
          />
          <.input
            :if={@checked == false}
            field={{f, :malcore}}
            type="checkbox"
            phx-click="toggle-checkbox"
            label="Create Malcore Account?"
          />

          <:actions>
            <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})
    socket = assign(socket, changeset: changeset, trigger_submit: false, checked: true)
    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, assign(socket, trigger_submit: true, changeset: changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}

      {:error, :failed_to_register_malcore} ->
        socket = put_flash(socket, :error, "failed to register with Malcore")

        {:noreply, socket}

      {:error, :failed_to_register} ->
        socket = put_flash(socket, :error, "Please try again later.")

        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end

  def handle_event("toggle-checkbox", _params, socket) do
    socket = assign(socket, checked: !socket.assigns.checked)

    {:noreply, socket}
  end
end
