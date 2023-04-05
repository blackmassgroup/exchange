defmodule VxUndergroundWeb.SampleLive.Index do
  use VxUndergroundWeb, :live_view

  alias VxUnderground.Tags
  alias VxUnderground.Services.S3
  alias VxUndergroundWeb.SampleChannel
  alias VxUnderground.Samples
  alias VxUnderground.Samples.Sample

  @impl true
  def mount(_params, _session, socket) do
    SampleChannel.join("sample:lobby", %{}, socket)

    if connected?(socket) do
      socket =
        assign(socket, size: :KB)
        |> assign(:search, "")
        |> assign(:samples, Samples.list_samples())
        |> assign(:tags, Tags.list_tags())

      {:ok, socket}
    else
      socket =
        assign(socket, :samples, [])
        |> assign(:search, "")
        |> assign(:size, :KB)

      {:ok, socket}
    end
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
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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

  def handle_event("search", %{"Hashes" => hashes}, socket)
      when byte_size(hashes) in [0, 32, 40, 64, 128] do
    socket =
      assign(socket, :samples, list_samples(%{hash: hashes}))
      |> assign(:search, hashes)

    {:noreply, socket}
  end

  def handle_event("search", %{"Hashes" => hashes}, socket) do
    socket =
      assign(socket, :samples, [])
      |> assign(:search, hashes)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:triage_report_complete, %{sample: sample}}, socket) do
    socket =
      assign(socket, :samples, [sample | socket.assigns.samples])
      |> put_flash(:info, "Sample #{sample.sha256}(sha256) finished processing.")

    {:noreply, socket}
  end


  defp list_samples(params \\ %{}) do
    Samples.list_samples(params)
  end

  # View functions

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

  def get_shown_number(size, :KB), do: size

  def get_shown_number(size, :MB), do: div(size, 1024)

  def get_shown_number(size, :GB), do: div(size, 1024) |> div(1024)
end
