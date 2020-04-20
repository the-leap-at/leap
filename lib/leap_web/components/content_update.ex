defmodule LeapWeb.Components.ContentUpdate do
  @moduledoc """
  Add content updates
  """
  use LeapWeb, :component
  use TypedStruct

  defmodule State do
    @moduledoc false
    @debounce 1000

    @typedoc "Content Component state"
    typedstruct do
      field :component_id, String.t(), enforce: true
      field :debounce, integer(), default: @debounce
      field :update_callback, function(), enforce: true
      field :initial_value, String.t(), enforce: true
    end

    def mount(socket) do
      {:ok, socket}
    end

    def update(assigns, socket) do
      state = %State{
        component_id: assigns.id,
        update_callback: assigns.update_callback,
        initial_value: assigns.value
      }

      state = add_debounce(assigns, state)
      {:ok, assign(socket, :state, state)}
    end

    defp add_debounce(%{debounce: debounce}, %State{} = state) when is_integer(debounce) do
      %State{state | debounce: debounce}
    end

    defp add_debounce(_assings, state), do: state
  end
end
