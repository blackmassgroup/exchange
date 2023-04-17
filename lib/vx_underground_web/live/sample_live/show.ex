defmodule VxUndergroundWeb.SampleLive.Show do
  use VxUndergroundWeb, :live_view

  alias VxUnderground.Services.{TriageSearch, VirusTotal}
  alias VxUnderground.Samples
  alias VxUndergroundWeb.SampleChannel

  import VxUndergroundWeb.SampleLive.Index, only: [generate_url_for_file: 1]

  require Logger

  @impl true
  def mount(%{"id" => sample_id} = _params, _session, socket) do
    if connected?(socket) do
      SampleChannel.join("sample:lobby", %{}, socket)

      sample = Samples.get_sample(sample_id)

      case sample do
        nil ->
          {:noreply,
           put_flash(socket, :error, "Sample does not exist") |> push_navigate(to: ~p(/samples))}

        _ ->
          virus_total =
            case VirusTotal.get_sample(sample.sha256) do
              {:ok, virus_total} ->
                virus_total

              {:error, _} ->
                :does_not_exist
            end

          triage =
            case TriageSearch.search(sample.sha256) do
              {:ok, %{"data" => []}} ->
                %{sample: sample}
                |> VxUnderground.ObanJobs.TriageUpload.new()
                |> Oban.insert()

                :triage_has_no_data

              {:ok, %{"data" => _} = response} ->
                response

              {:error, _} = response ->
                Logger.error(triage_search_error: response)

                %{sample: sample}
                |> VxUnderground.ObanJobs.TriageUpload.new()
                |> Oban.insert()

                :still_processing
            end
            |> IO.inspect(label: :triage)

          {:ok,
           socket
           |> assign(:page_title, page_title(socket.assigns.live_action))
           |> assign(:sample, sample)
           |> assign(:virus_total, virus_total)
           |> assign(:triage, triage)}
      end
    else
      {:ok, socket}
    end
  end

  @impl true
  def handle_info({:triage_report_complete, %{sample: sample}}, socket) do
    socket =
      assign(socket, :samples, [sample | socket.assigns.samples])
      |> put_flash(:info, "Sample #{sample.sha256}(sha256) finished processing.")

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Sample"
  defp page_title(:edit), do: "Edit Sample"
end
