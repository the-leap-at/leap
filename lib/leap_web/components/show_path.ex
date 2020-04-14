defmodule LeapWeb.Components.ShowPath do
  @moduledoc """
  - Shows paths
  """
  use LeapWeb, :component
  use TypedStruct

  alias LeapWeb.Components.ShowPathView
  alias Leap.Answers
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

  def update(%{id: component_id, path_id: path_id}, socket) do
    path = Answers.get!(Path, path_id)

    state = %State{
      component_id: component_id,
      path: path
    }

    {:ok, assign(socket, :state, state)}
  end

  def render(assigns) do
    Phoenix.View.render(ShowPathView, "show_path.html", assigns)
  end
end
