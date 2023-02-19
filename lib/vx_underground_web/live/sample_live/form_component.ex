defmodule VxUndergroundWeb.SampleLive.FormComponent do
  use VxUndergroundWeb, :live_component

  alias VxUnderground.Samples

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage sample records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="sample-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= Phoenix.HTML.Form.hidden_input(f, :hash) %>
        <%= Phoenix.HTML.Form.hidden_input(f, :size) %>
        <%= Phoenix.HTML.Form.hidden_input(f, :type) %>
        <%= Phoenix.HTML.Form.hidden_input(f, :first_seen) %>

        <div
          class="flex items-center justify-center w-full"
          phx-drop-target={@uploads.s3_object_key.ref}
        >
          <label
            for="dropzone-file"
            class="flex flex-col items-center justify-center w-full h-64 border-2 border-gray-300 border-dashed rounded-lg cursor-pointer bg-slate-50"
          >
            <div class="flex flex-col items-center justify-center pt-5 pb-6">
              <svg
                aria-hidden="true"
                class="w-10 h-10 mb-3 text-gray-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"
                >
                </path>
              </svg>
              <p class="mb-2 text-sm text-gray-500 dark:text-gray-400">
                <span class="font-semibold">Click "browse" below to upload</span> or drag and drop your files here.
              </p>
              <p class="text-xs text-gray-500 dark:text-gray-400">
                All file types accepted, 10 file limit, 50MB limit per file.
              </p>
            </div>
            <.live_file_input
              upload={@uploads.s3_object_key}
              label="S3 object key"
              auto_upload="true"
            />
          </label>
        </div>

        <%= for entry <- @uploads.s3_object_key.entries do %>
          <article class="upload-entry">
            <figure>
              <figcaption><%= entry.client_name %></figcaption>
            </figure>

            <%!-- entry.progress will update automatically for in-flight entries --%>
            <progress
              value={entry.progress}
              max="100"
              style="width: 95%; height: 10px;border-radius: 25px;"
            >
              <%= entry.progress %>%
            </progress>

            <button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              aria-label="cancel"
            >
              &times;
            </button>

            <%= for err <- upload_errors(@uploads.s3_object_key, entry) do %>
              <p class="alert alert-danger"><%= error_to_string(err) %></p>
            <% end %>
          </article>
        <% end %>
        <:actions>
          <.button phx-disable-with="Saving...">Save Sample</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def error_to_string(:external_client_failure), do: "AWS Error"

  @impl true
  def update(%{sample: sample} = assigns, socket) do
    changeset = Samples.change_sample(sample)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> allow_upload(:s3_object_key, accept: :any, max_entries: 10, external: &presign_upload/2, max_file_size: 50_000_000)}
  end

  defp presign_upload(entry, socket) do
    bucket = "vxug"
    key = "#{entry.client_name}"

    {:ok, presigned_url} = ExAws.Config.new(:s3) |> ExAws.S3.presigned_url(:put, bucket, key)
    meta = %{uploader: "S3", bucket: bucket, key: key, url: presigned_url}

    {:ok, meta, socket}
  end

  @impl true
  def handle_event("validate", %{"sample" => sample_params}, socket) do
    changeset =
      socket.assigns.sample
      |> Samples.change_sample(sample_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  def handle_event("save", %{"sample" => sample_params}, socket) do
    save_sample(socket, socket.assigns.action, sample_params)
  end

  defp save_sample(socket, :edit, sample_params) do
    case Samples.update_sample(socket.assigns.sample, sample_params) do
      {:ok, _sample} ->
        {:noreply,
         socket
         |> put_flash(:info, "Sample updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
    # |> VxUnderground.Services.Triage.submit(sample.s3_object_key)
    # |> VxUnderground.Services.HybridAnalysis.submit(sample.s3_object_key)
    # |> VxUnderground.Services.VirusTotal.submit(sample.s3_object_key)
  end

  defp save_sample(socket, :new, sample_params) do
    new_params =
      case socket.assigns.uploads.s3_object_key.entries |> List.first() do
        nil ->
          %{}

        upload ->
          region = "eu-central-1"
          bucket = "vxug"
          url = "http://#{bucket}.s3.#{region}.wasabisys.com/#{upload.client_name}"

          %{
            "type" => upload.client_type,
            "size" => upload.client_size,
            "hash" => upload.client_name,
            "s3_object_key" => url,
            "first_seen" => DateTime.utc_now()
          }
      end

    sample_params = Map.merge(sample_params, new_params)

    case Samples.create_sample(sample_params) do
      {:ok, _sample} ->
        {:noreply,
         socket
         |> put_flash(:info, "Sample created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
