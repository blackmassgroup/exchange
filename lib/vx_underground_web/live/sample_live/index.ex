defmodule VxUndergroundWeb.SampleLive.Index do
  use VxUndergroundWeb, :live_view

  alias VxUnderground.Tags
  alias VxUnderground.Samples
  alias VxUnderground.Samples.Sample
  alias VxUndergroundWeb.SampleLive.SortingForm
  alias VxUndergroundWeb.SampleLive.FilterForm

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :samples, list_samples())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket =
      parse_params(socket, params)
      |> assign_samples()
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  defp generate_url_for_file(s3_object_key) do
    opts = [expires_in: 300]

    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(:get, "vxug", s3_object_key, opts)
    |> case do
      {:ok, url} -> url
      _ -> "#"
    end
  end

  defp assign_samples(socket) do
    params = merge_and_sanitize_params(socket)

    samples = list_samples(params)
    tags = Tags.list_tags() |> Enum.map(&[value: &1.id, key: &1.name])

    socket
    |> assign(:samples, samples)
    |> assign(:tags, tags)
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

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    sample = Samples.get_sample!(id)
    {:ok, _} = Samples.delete_sample(sample)

    {:noreply, assign(socket, :samples, list_samples())}
  end

  defp merge_and_sanitize_params(socket, overrides \\ %{}) do
    %{sorting: sorting, filter: filter} = socket.assigns

    %{}
    |> Map.merge(sorting)
    |> Map.merge(filter)
    |> Map.merge(overrides)
    |> Map.drop([:total_count])
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Map.new()
  end

  defp parse_params(socket, params) do
    with {:ok, sorting_opts} <- SortingForm.parse(params),
         {:ok, filter_opts} <- FilterForm.parse(params) do
      socket
      |> assign_filter(filter_opts)
      |> assign_sorting(sorting_opts)
    else
      _error ->
        socket
        |> assign_sorting()
        |> assign_filter()
        |> put_flash(:error, "Invalid filter params")
    end
  end

  defp assign_sorting(socket, overrides \\ %{}) do
    opts = Map.merge(SortingForm.default_values(), overrides)

    assign(socket, :sorting, opts)
  end

  defp assign_filter(socket, overrides \\ %{}) do
    assign(socket, :filter, FilterForm.default_values(overrides))
  end

  defp list_samples(params \\ %{}) do
    Samples.list_samples(params)
  end

  @impl true
  def handle_info({:update, opts}, socket) do
    params = merge_and_sanitize_params(socket, opts)
    path = "/samples?" <> URI.encode_query(params)

    {:noreply, push_patch(socket, to: path, replace: true)}
  end

  def handle_info({:triage_report_complete, _}, socket) do
    socket = assign_samples(socket) |> put_flash(:info, "Sample finished processing.")

    {:noreply, socket}
  end

  def handle_info({:kickoff_triage_report, %{upload: upload, sample: sample}}, socket) do
    kickoff_triage_report(upload, sample)

    {:noreply, socket}
  end

  defp kickoff_triage_report(upload, sample) do
    with(
      {:ok, presigned_url} <-
        ExAws.Config.new(:s3) |> ExAws.S3.presigned_url(:get, "vxug", "#{upload.client_name}"),
      {:ok, id} <- VxUnderground.Services.Triage.upload(presigned_url) |> IO.inspect(label: :triage_upload),
      {:ok, hashes} <- VxUnderground.Services.Triage.get_sample(id)|> IO.inspect(label: :triage_get),
      {:ok, complete_params} <- build_complete_sample_params(hashes),
      {:ok, _sample} <- Samples.update_sample(sample, complete_params)
    ) do
      send(self(), {:triage_report_complete, %{}})
    else
      _ ->
        :error
    end
  end

  defp build_complete_sample_params(hashes) do
    {:ok,
     %{
       "md5" => hashes["md5"],
       "sha1" => hashes["sha1"],
       "sha256" => hashes["sha256"],
       "sha512" => hashes["sha512"]
     }}
  end

  def truncate_hash(nil), do: ""

  def truncate_hash(hash) do
    String.slice(hash, 0..20) <> "..." <> String.slice(hash, -20..-1)
  end
end
