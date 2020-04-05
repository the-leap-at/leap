defmodule LeapWeb.Components.EditPath do
  @moduledoc """
  - Updates paths
  """
  use LeapWeb, :component
  use TypedStruct

  alias LeapWeb.ComponentsView
  alias Leap.Answers
  alias Leap.Answers.Schema.Path

  @delay 500

  defmodule State do
    @moduledoc false

    @typedoc "EditPath Component state"
    typedstruct do
      field :component_id, String.t(), enforce: true
      field :path, Path.t(), enforce: true
      field :path_changeset, Ecto.Changeset.t(Path.t())
    end
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{id: component_id, path_id: path_id}, socket) do
    path = Answers.get!(Path, path_id)

    state = %State{
      component_id: component_id,
      path: path,
      path_changeset: Answers.change_path(path)
    }

    {:ok, assign(socket, :state, state)}
  end

  def update(%{action: :update_path, params: path_params}, %{assigns: %{state: state}} = socket) do
    case Answers.update_path(state.path, path_params) do
      {:ok, path} ->
        state = %State{state | path: path, path_changeset: Answers.change_path(path)}

        {:ok, assign(socket, :state, state)}

      {:error, changeset} ->
        state = %State{state | path_changeset: changeset}

        {:ok, assign(socket, :state, state)}
    end
  end

  def handle_event("update_path", %{"path" => path_params}, %{assigns: %{state: state}} = socket) do
    if has_values?(path_params) do
      send(
        self(),
        {:delay_action, @delay, {__MODULE__, state.component_id, :update_path, path_params}}
      )
    end

    {:noreply, socket}
  end

  def render(assigns) do
    Phoenix.View.render(ComponentsView, "edit_path.html", assigns)
  end
end
