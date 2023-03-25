defmodule VxUndergroundWeb.SampleLive.Index do
  use VxUndergroundWeb, :live_view

  alias VxUnderground.Services.S3
  alias VxUndergroundWeb.SampleChannel
  alias VxUnderground.Tags
  alias VxUnderground.Samples
  alias VxUnderground.Samples.Sample
  alias VxUndergroundWeb.SampleLive.SortingForm
  alias VxUndergroundWeb.SampleLive.FilterForm

  @impl true
  def mount(_params, _session, socket) do
    SampleChannel.join("sample:lobby", %{}, socket)

    {:ok, assign(socket, size: :KB) |> assign_samples()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket =
      parse_params(socket, params)
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  def generate_url_for_file(s3_object_key) do
    opts = [expires_in: 300]
    bucket = S3.get_bucket()

    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(:get, bucket, s3_object_key, opts)
    |> case do
      {:ok, url} -> url
      _ -> "#"
    end
  end

  defp assign_samples(socket) do
    samples = list_samples()
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

  def handle_event("size-change", params, socket) do
    {:noreply, assign(socket, :size, String.to_atom(params["size"]))}
  end

  defp merge_and_sanitize_params(socket, overrides \\ %{}) do
    %{sorting: sorting, filter: filter} = socket.assigns

    %{}
    |> Map.merge(sorting)
    |> Map.merge(filter)
    |> Map.merge(overrides)
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

  def handle_info({:update, opts}, socket) do
    samples =
      merge_and_sanitize_params(socket, opts)
      |> IO.inspect(label: :waldo_5)
      |> list_samples()

    {:noreply, assign(socket, :samples, samples)}
  end

  def handle_info({:triage_report_complete, %{sample: sample}}, socket) do
    socket =
      assign_samples(socket)
      |> put_flash(:info, "Sample #{sample.sha256}(sha256) finished processing.")

    {:noreply, socket}
  end

  def handle_info({:triage_processing_complete, %{sample: sample}}, socket) do
    %{sample: sample}
    |> VxUnderground.ObanJobs.TriageUpload.new()
    |> Oban.insert()

    {:noreply, socket}
  end

  def get_shown_number(size, :KB), do: size

  def get_shown_number(size, :MB), do: div(size, 1024)

  def get_shown_number(size, :GB), do: div(size, 1024) |> div(1024)

  def truncate_hash(nil), do: ""

  def truncate_hash(hash) do
    String.slice(hash, 0..20) <> "..." <> String.slice(hash, -20..-1)
  end
end
