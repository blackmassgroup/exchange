defmodule VxUndergroundWeb.Layouts do
  use VxUndergroundWeb, :html

  embed_templates "layouts/*"

  def toggle_mobile_menu() do
    JS.toggle(
      to: "#mobile-menu-canvas-backdrop",
      in: {"transition-opacity ease-linear duration-300", "opacity-0", "opacity-100"},
      out: {"transition-opacity ease-linear duration-300", "opacity-100", "opacity-0"}
    )
    |> JS.toggle(
      to: "#mobile-menu-fixed-insert",
      in: {"transition-opacity ease-linear duration-300", "opacity-0", "opacity-100"},
      out: {"transition-opacity ease-linear duration-300", "opacity-100", "opacity-0"}
    )
    |> JS.toggle(
      to: "#mobile-menu-canvas-menu-translate",
      in: {"transition ease-in-out duration-300 transform", "-translate-x-full", "translate-x-0"},
      out: {"transition ease-in-out duration-300 transform", "translate-x-0", "-translate-x-full"}
    )
    |> JS.toggle(
      to: "#mobile-menu-close",
      in: {"ease-in-out duration-300", "opacity-0", "opacity-100"},
      out: {"ease-in-out duration-300", "opacity-100", "opacity-0"}
    )
    |> JS.toggle(
      to: "#mobile-menu-canvas-menu",
      in: {"transition-opacity ease-linear duration-300", "opacity-0", "opacity-100"},
      out: {"transition-opacity ease-linear duration-300", "opacity-100", "opacity-0"}
    )
  end

  def loading_component(assigns) do
    ~H"""
    <div
      :if={not Phoenix.LiveView.connected?(@socket) and @samples == []}
      class="p-6 m-6 animate-pulse"
    >
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-900"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
      <div class="h-4 mb-6 rounded bg-emerald-800"></div>
    </div>
    """
  end
end
