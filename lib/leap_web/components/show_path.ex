defmodule LeapWeb.Components.ShowPath do
  @moduledoc """
  - Shows paths
  """
  use LeapWeb, :component
  use TypedStruct

  alias Leap.Answers.Schema.Path

  defmodule State do
    @moduledoc false

    @typedoc "ShowPath Component state"
    typedstruct do
      field :component_id, String.t(), enforce: true
      field :path, Path.t(), enforce: true
    end
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{id: component_id, path: path}, socket) do
    state = %State{
      component_id: component_id,
      path: path
    }

    {:ok, assign(socket, :state, state)}
  end
end
