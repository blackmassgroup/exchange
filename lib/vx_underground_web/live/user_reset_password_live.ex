defmodule VxUndergroundWeb.UserResetPasswordLive do
  use VxUndergroundWeb, :live_view

  alias VxUnderground.Accounts

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center h-screen">
      <div class="mx-auto max-w-sm">
        <.header class="text-center">
          <span class="text-white">Reset virus.exchange Password </span>
        </.header>

        <.simple_form
          :let={f}
          for={@changeset}
          id="reset_password_form"
          phx-submit="reset_password"
          phx-change="validate"
        >
          <.error :if={@changeset.action == :insert}>
            Oops, something went wrong! Please check the errors below.
          </.error>

          <.input field={{f, :password}} type="password" label="New password" required />
          <.input
            field={{f, :password_confirmation}}
            type="password"
            label="Confirm new password"
            required
          />
          <:actions>
            <.button phx-disable-with="Resetting..." class="w-full">Reset Password</.button>
          </:actions>
        </.simple_form>

        <p class="text-center mt-4 text-sm text-emerald-500">
          <.link href={~p"/users/register"}>Register</.link>
          | <.link href={~p"/users/log_in"}>Log in</.link>
        </p>
      </div>
    </div>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_user_and_token(socket, params)

    socket =
      case socket.assigns do
        %{user: user} ->
          assign(socket, :changeset, Accounts.change_user_password(user))

        _ ->
          socket
      end

    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def handle_event("reset_password", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: ~p"/users/log_in")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end
end
