defmodule ExchangeWeb.UserForgotPasswordLive do
  use ExchangeWeb, :live_view

  alias Exchange.Accounts

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center h-screen">
      <div class="mx-auto max-w-sm">
        <.header class="text-center">
          <span class="text-white">Forgot your password?</span>
          <:subtitle>We'll send a password reset link to your inbox</:subtitle>
        </.header>

        <.simple_form :let={f} id="reset_password_form" for={%{}} as={:user} phx-submit="send_email">
          <.input field={{f, :email}} type="email" placeholder="Email" required />
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full">
              Send password reset instructions
            </.button>
          </:actions>
        </.simple_form>
        <p class="text-center mt-4 text-emerald-500 text-sm">
          <.link href={~p"/users/register"}>Register</.link>
          | <.link href={~p"/users/log_in"}>Log in</.link>
        </p>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
