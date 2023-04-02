defmodule VxUndergroundWeb.RoleLive.FormComponent do
  use VxUndergroundWeb, :live_component

  alias VxUnderground.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage role records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="role-form"
        phx-target={@myself}
        phx-change="save"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="Name" />
        <.input field={{f, :permissions}} type="permissions" label="Permissions" phx-target={@myself} />
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{role: role} = assigns, socket) do
    changeset = Accounts.change_role(role)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"role" => role_params}, socket) do
    changeset =
      socket.assigns.role
      |> Accounts.change_role(role_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"role" => role_params}, socket) do
    save_role(socket, socket.assigns.action, role_params)
  end

  @impl true
  def handle_event(
        "role-permission-change",
        %{"resource" => resource, "permission" => permission} = params,
        socket
      ) do
    %{role: %{permissions: permissions}} = socket.assigns

    original_resource_permissions = Map.get(permissions, resource, [])

    new_permissions =
      if Map.get(params, "value") === "on" do
        Map.put(
          permissions,
          resource,
          original_resource_permissions ++ [permission]
        )
      else
        Map.put(
          permissions,
          resource,
          original_resource_permissions -- [permission]
        )
      end
      # |> Jason.encode!
      |> IO.inspect(label: :new_permissions)

    {:ok, role} =
      socket.assigns.role
      |> Accounts.update_role(%{permissions: new_permissions})

    {:noreply,
     assign(socket, :role, role)
     |> put_flash(:info, "Role updated successfully")
     |> push_patch(to: ~p(/roles/#{role.id}/show/edit))}
  end

  defp save_role(socket, :edit, role_params) do
    permissions = Ecto.Changeset.fetch_field!(socket.assigns.changeset, :permissions)
    role_params = Map.put(role_params, "permissions", permissions)

    case Accounts.update_role(socket.assigns.role, role_params) do
      {:ok, role} ->
        {:noreply,
         socket
         |> put_flash(:info, "Role updated successfully")
         |> push_navigate(to: ~p(/roles/#{role.id}/show/edit))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_role(socket, :new, role_params) do
    case Accounts.create_role(role_params) do
      {:ok, role} ->
        {:noreply,
         socket
         |> put_flash(:info, "Role created successfully")
         |> push_navigate(to: ~p(/roles))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
