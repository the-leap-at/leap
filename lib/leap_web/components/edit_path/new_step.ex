defmodule LeapWeb.Components.EditPath.NewStep do
  @moduledoc "Create new Step"

  use LeapWeb, :component
  alias Leap.Answers.Schema.Path
  alias LeapWeb.ComponentsView

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    Phoenix.View.render(ComponentsView, "new_step.html", assigns)
  end
end
