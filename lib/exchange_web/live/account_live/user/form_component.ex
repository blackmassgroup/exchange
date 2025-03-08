defmodule ExchangeWeb.AccountLive.User.FormComponent do
  use ExchangeWeb, :live_component

  alias Exchange.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage user records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :email}} type="text" label="Email" />
        <.input field={{f, :username}} type="text" label="Username" />
        <.input field={{f, :tier}} type="text" label="Tier" />
        <.input field={{f, :role_id}} type="select" label="Role" options={@roles} />

        <:actions>
          <.button phx-disable-with="Saving...">Save User</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Accounts.User.role_changeset(user, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.User.email_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user_roles_and_permissions(socket.assigns.user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "user updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_user(_socket, :new, _user_params) do
    # case Accounts.create_user(user_params) do
    #   {:ok, _user} ->
    #     {:noreply,
    #      socket
    #      |> put_flash(:info, "user created successfully")
    #      |> push_navigate(to: socket.assigns.navigate)}

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     {:noreply, assign(socket, changeset: changeset)}
    # end
  end
end
