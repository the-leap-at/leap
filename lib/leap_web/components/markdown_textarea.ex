defmodule LeapWeb.Components.MarkdownTextarea do
  @moduledoc """
  Markdown textarea with preview.
  Should be hightly configurable and extensible. Eg be able to add atoolbar to add predefined text
  """

  use LeapWeb, :component
  use TypedStruct

  defmodule State do
    @moduledoc false

    @debounce 1000

    @typedoc "Markdown Texarea Component state"
    typedstruct do
      field :component_id, String.t(), enforce: true
      field :debounce, integer(), default: @debounce
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
    value = assigns.form.params[to_string(assigns.field)] || assigns.value

    state = %State{
      component_id: assigns.id,
      form: assigns.form,
      field: assigns.field,
      value: value
    }

    state = add_debounce(assigns, state)

    {:ok, assign(socket, :state, state)}
  end

  def handle_event("store_value", %{"value" => value}, %{assigns: %{state: state}} = socket) do
    state = %State{state | value: value}
    {:noreply, assign(socket, :state, state)}
  end

  def handle_event("switch_preview", _params, %{assigns: %{state: state}} = socket) do
    state = %State{state | preview: not state.preview}
    {:noreply, assign(socket, :state, state)}
  end

  defp add_debounce(%{debounce: debounce}, %State{} = state) when is_integer(debounce) do
    %State{state | debounce: debounce}
  end

  defp add_debounce(_assings, state), do: state

  # hide the textarea while in preview mode, but to be still part of the form
  defp hidden(preview) do
    if preview, do: "is-hidden"
  end
end
