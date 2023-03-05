defmodule VxUndergroundWeb.SampleLive.Show do
  use VxUndergroundWeb, :live_view

  alias VxUnderground.Services.{TriageSearch, VirusTotal}
  alias VxUnderground.{Samples, Tags}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    sample = Samples.get_sample!(id)

    virus_total =
      case VirusTotal.get_sample(sample.sha256) do
        {:ok, virus_total} ->
          virus_total

        {:error, _} ->
          # ExAws.S3.get_object("vx-ug", sample.s3_object_key)
          # |> ExAws.request!()
          # |> Map.get(:body)
          # |> VirusTotalPost.submit_for_processing()
          "File doesn't exist on virus total yet."
      end

    triage =
      case TriageSearch.search(sample.sha256) do
        {:ok, %{"data" => data}} ->
          data

        {:error, _} ->
          "Could not process file with Triage. Please try again later."
      end

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:sample, sample)
     |> assign(:tags, Tags.list_tags() |> Enum.map(&[value: &1.id, key: &1.name]))
     |> assign(:virus_total, virus_total)
     |> assign(:triage, triage)}
  end

  defp page_title(:show), do: "Show Sample"
  defp page_title(:edit), do: "Edit Sample"
end
