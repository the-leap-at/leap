defmodule LeapWeb.PathComponent do
  @moduledoc """
  - Updates paths
  - Creates steps
  """
  use Phoenix.LiveComponent
  use TypedStruct

  alias LeapWeb.PathsView
  alias Leap.Answers
  alias Leap.Answers.Schema.Path

  defmodule State do
    @moduledoc false

    @typedoc "PathComponent state"
    typedstruct do
      field :component_id, String.t(), enforce: true
      field :path, Path.t(), enforce: true
      field :path_changeset, Ecto.Changeset.t(Path.t())
    end
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{id: component_id, path: %Path{} = path}, socket) do
    state = %State{
      component_id: component_id,
      path: path,
      path_changeset: Answers.change_path(path)
    }

    {:ok, assign(socket, :state, state)}
  end

  def update(%{action: :update_path, params: params}, %{assigns: %{state: state}} = socket) do
    case Answers.update_path(state.path, params) do
      {:ok, path} ->
        state = %State{state | path: path, path_changeset: Answers.change_path(path)}

        {:ok, assign(socket, :state, state)}

      {:error, changeset} ->
        state = %State{state | path_changeset: changeset}

        {:ok, assign(socket, :state, state)}
    end
  end

  def handle_event("update_path", %{"path" => path_params}, %{assigns: %{state: state}} = socket) do
    send(self(), {:delay_action, {state.component_id, :update_path, path_params}})
    {:noreply, socket}
  end

  def render(assigns) do
    Phoenix.View.render(PathsView, "path.html", assigns)
  end
end
