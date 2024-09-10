defmodule ExchangeWeb.SampleLive.Show do
  use ExchangeWeb, :live_view

  alias Exchange.Services.{TriageSearch}
  alias Exchange.Samples
  alias ExchangeWeb.SampleChannel

  import ExchangeWeb.SampleLive.Index, only: [generate_url_for_file: 1]

  require Logger

  @impl true
  def mount(%{"id" => sample_id} = _params, _session, socket) do
    if connected?(socket) do
      SampleChannel.join("sample:lobby", %{}, socket)

      with(
        {sample_id, ""} <- Integer.parse(sample_id),
        sample <- Samples.get_sample(sample_id)
      ) do
        case sample do
          nil ->
            {:ok,
             put_flash(socket, :error, "Sample does not exist") |> push_navigate(to: ~p(/samples))}

          _ ->
            {:ok,
             socket
             |> assign(:page_title, page_title(socket.assigns.live_action))
             |> assign(:sample, sample)
             |> assign(:triage, :triage_not_processed)}
        end
      else
        _ ->
          {:ok,
           put_flash(socket, :error, "Sample does not exist") |> push_navigate(to: ~p(/samples))}
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

  @impl true
  def handle_event("start-triage-processing", _params, socket) do
    sample = socket.assigns.sample

    triage =
      case TriageSearch.search(sample.sha256) do
        {:ok, %{"data" => []}} ->
          %{sample: sample}
          |> Exchange.Services.TriageUpload.new()
          |> Oban.insert()

          :triage_has_no_data

        {:ok, %{"data" => _} = response} ->
          response

        {:error, _} = response ->
          Logger.error(triage_search_error: response)

          %{sample: sample}
          |> Exchange.Services.TriageUpload.new()
          |> Oban.insert()

          :still_processing
      end

    {:noreply, assign(socket, :triage, triage)}
  end

  defp page_title(:show), do: "Show Sample"
  defp page_title(:edit), do: "Edit Sample"
end
