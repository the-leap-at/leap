defmodule LeapWeb.Components.MarkdownTextarea do
  @moduledoc """
  Markdown textarea with preview.
  Should be hightly configurable and extensible. Eg be able to add atoolbar to add predefined text
  """

  use LeapWeb, :component
  use TypedStruct

  defmodule State do
    @moduledoc false

    @typedoc "Markdown Texarea Component state"
    typedstruct do
      field :component_id, String.t(), enforce: true
      field :form, Phoenix.HTML.Form.t(), enforce: true
      field :field, String.t(), enforce: true
      field :value, String.t()
      field :preview, boolean(), default: false
    end
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    state = %State{
      component_id: assigns.id,
      form: assigns.form,
      field: assigns.field,
      value: assigns.value
    }

    {:ok, assign(socket, :state, state)}
  end

  def handle_event("store_value", %{"value" => value}, %{assigns: %{state: state}} = socket) do
    state = %State{state | value: value}
    {:noreply, assign(socket, :state, state)}
  end

  def handle_event("switch_preview", params, %{assigns: %{state: state}} = socket) do
    state = %State{state | preview: not state.preview}
    {:noreply, assign(socket, :state, state)}
  end

  def show_edit(state) do
    not state.preview
  end

  def show_preview(state) do
    state.preview
  end
end
