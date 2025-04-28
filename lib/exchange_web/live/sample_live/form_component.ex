defmodule ExchangeWeb.SampleLive.FormComponent do
  use ExchangeWeb, :live_component

  alias Exchange.Samples
  alias Exchange.Sample
  alias Exchange.Services.S3
  alias Exchange.ObanJobs.Vt.SubmitVt

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <span class="text-slate-200">{@title}</span>
        <:subtitle><span class="text-slate-300"> Something new? Interesting...</span></:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="sample-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        {Phoenix.HTML.Form.hidden_input(f, :hash)}
        {Phoenix.HTML.Form.hidden_input(f, :size)}
        {Phoenix.HTML.Form.hidden_input(f, :type)}
        {Phoenix.HTML.Form.hidden_input(f, :first_seen)}

        <div
          class="flex items-center justify-center w-full"
          phx-drop-target={@uploads.s3_object_key.ref}
        >
          <label
            for="dropzone-file"
            class="flex flex-col items-center justify-center w-full h-64 border-2 border-gray-300 border-dashed rounded-lg cursor-pointer bg-slate-50 bg-zinc-800 border-zinc-600 text-slate-200"
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
              <p class="mb-2 text-sm text-gray-500 text-gray-400">
                <span class="font-semibold">Click "browse" below to upload</span>
                or drag and drop your files here.
              </p>
              <p class="text-xs text-gray-500 text-gray-400">
                All file types accepted, 10 file limit, 50MB limit per file.
              </p>
            </div>
            <.live_file_input upload={@uploads.s3_object_key} />
          </label>
        </div>

        <%= for entry <- @uploads.s3_object_key.entries do %>
          <article class="upload-entry">
            <figure>
              <figcaption class="text-gray-500">{entry.client_name}</figcaption>
            </figure>

            <%!-- entry.progress will update automatically for in-flight entries --%>
            <progress
              value={entry.progress}
              max="100"
              style="width: 95%; height: 10px;border-radius: 25px;"
            >
              {entry.progress}%
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
              <p class="alert alert-danger">{error_to_string(err)}</p>
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
     |> allow_upload(:s3_object_key,
       accept: :any,
       max_entries: 10,
       external: &presign_upload/2,
       max_file_size: Samples.size_limit()
     )}
  end

  defp presign_upload(entry, socket) do
    bucket = S3.get_minio_bucket()
    key = "#{entry.client_name}"
    config_opts = S3.minio_config()

    opts = [
      expires_in: 3600,
      query_params: [{"Content-Type", entry.client_type}]
    ]

    {:ok, presigned_url} =
      ExAws.Config.new(:s3, config_opts)
      |> ExAws.S3.presigned_url(:put, bucket, key, opts)

    meta = %{uploader: "S3", key: key, url: presigned_url}

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
         |> push_navigate(to: socket.assigns.navigate, replace: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_sample(%{assigns: %{uploads: %{s3_object_key: uploads}}} = socket, :new, _params) do
    Enum.reduce(uploads.entries, Ecto.Multi.new(), fn upload, acc ->
      build_sample_and_rename_uploads(upload, socket.assigns.current_user.id)
      |> then(&(acc |> Ecto.Multi.insert(upload.client_name, &1)))
    end)
    |> Exchange.Repo.Local.transaction()
    |> case do
      {:ok, samples} ->
        if Application.get_env(:exchange, :env) != :test do
          Enum.each(
            samples,
            fn {_name, sample} ->
              Phoenix.PubSub.broadcast(Exchange.PubSub, "samples", {:new_sample, sample})
            end
          )

          Enum.map(samples, fn {_name, sample} ->
            %{
              "sha256" => sample.sha256,
              "is_new" => true,
              "is_first_request" => true
            }
            |> SubmitVt.new()
            |> Oban.insert()
          end)
        end

        socket =
          socket
          |> put_flash(:info, "Sample(s) created successfully")
          |> push_navigate(to: ~p"/samples", replace: true)

        {:noreply, socket}

      {:error, failed_operation, failed_value, _changes_so_far} ->
        # TODO Delete Orphaned Files
        errors =
          Enum.map(failed_value.errors, fn {field, {msg, _}} ->
            "#{failed_operation} #{field} #{msg}"
          end)
          |> Enum.join(". ")

        message = "There was a problem with one or more of your uploads. #{errors}"

        {:noreply,
         put_flash(socket, :error, message) |> push_navigate(to: ~p"/samples", replace: true)}
    end
  end

  defp build_sample_and_rename_uploads(%{client_type: _, client_name: _} = upload, user_id) do
    file_binary = get_s3_object({:error, :starting}, upload.client_name)

    with %{} = attrs <- Samples.build_sample_params(file_binary, upload, user_id),
         {:ok, _} <- S3.rename_uploaded_file(attrs.sha256, upload.client_name),
         opts = %{"last_analysis_results" => %{"Kaspersky" => %{"result" => upload.client_name}}},
         {:ok, _} <- S3.copy_file_to_daily_backups(attrs.sha256, true, opts) do
      Sample.changeset(%Sample{}, attrs)
    else
      _ ->
        {:error, :s3_rename_error}
    end
  end

  defp get_s3_object({:error, _}, client_name) do
    config_opts = S3.minio_config()

    S3.get_minio_bucket()
    |> ExAws.S3.get_object(client_name)
    |> ExAws.request(config_opts)
    |> get_s3_object(client_name)
  end

  defp get_s3_object({:ok, response}, _client_name) do
    Map.get(response, :body)
  end
end
