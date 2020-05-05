defmodule LeapWeb.Components.MarkdownTextarea do
  @moduledoc """
  Markdown textarea with preview.
  Should be hightly configurable and extensible. Eg be able to add atoolbar to add predefined text
  """

  use LeapWeb, :component
  use TypedStruct

  @debounce 1000

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    value = assigns.form.params[to_string(assigns.field)] || assigns.value

    assigns = Map.merge(assigns, %{value: value, preview: false, debounce: @debounce})

    {:ok, assign(socket, assigns)}
  end

  def handle_event("switch_preview", _params, %{assigns: %{preview: preview}} = socket) do
    {:noreply, assign(socket, :preview, not preview)}
  end

  # hide the textarea while in preview mode, but to be still part of the form
  defp hidden(preview) do
    if preview, do: "is-hidden"
  end
end
