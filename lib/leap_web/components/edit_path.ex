defmodule LeapWeb.Components.EditPath do
  @moduledoc """
  - Updates paths

  ### Example of delayed action
  ```


  ```
  """
  use LeapWeb, :component
  use TypedStruct

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

  def update(%{id: component_id, path: path}, socket) do
    state = %State{
      component_id: component_id,
      path: path,
      path_changeset: Answers.change_path(path)
    }

    {:ok, assign(socket, :state, state)}
  end

  def handle_event("update_path", %{"path" => path_params}, %{assigns: %{state: state}} = socket) do
    send(
      self(),
      {:delay_action, @delay, {__MODULE__, state.component_id, :update_path, path_params}}
    )

    {:noreply, socket}
  end

  # this should be changed to publish
  def handle_event("publish_path", %{"path" => path_params}, %{assigns: %{state: state}} = socket) do
    case Answers.update_path(state.path, path_params) do
      {:ok, path} ->
        state = %State{state | path: path, path_changeset: Answers.change_path(path)}
        socket = assign(socket, :state, state)
        {:noreply, push_patch(socket, to: Routes.live_path(socket, LeapWeb.PathLive, path.id))}

      {:error, changeset} ->
        state = %State{state | path_changeset: changeset}
        {:noreply, assign(socket, :state, state)}
    end
  end
end
