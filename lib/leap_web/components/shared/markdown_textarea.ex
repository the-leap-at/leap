defmodule LeapWeb.Components.Shared.MarkdownTextarea do
  @moduledoc """
  Markdown textarea with preview.
  Should be hightly configurable and extensible. Eg be able to add atoolbar to add predefined text
  """

  use LeapWeb, :component

  def mount(socket) do
    {:ok, assign(socket, :preview, false)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("switch_preview", _params, %{assigns: %{preview: preview}} = socket) do
    {:noreply, assign(socket, :preview, not preview)}
  end

  # hide the textarea while in preview mode, but to be still part of the post_form
  defp hidden(preview) do
    if preview, do: "is-hidden"
  end
end
