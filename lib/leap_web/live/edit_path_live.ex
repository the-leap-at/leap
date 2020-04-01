defmodule LeapWeb.EditPathLive do
  @moduledoc "Initiate update for paths"
  use Phoenix.LiveView
  use TypedStruct

  alias Leap.Answers
  alias Leap.Answers.Schema.Path
  alias LeapWeb.PathsView
  alias LeapWeb.PathComponent

  defmodule State do
    @moduledoc false

    @typedoc "EditPathLive state"
    typedstruct do
      field :timer_ref, reference() | nil
    end
  end

  def mount(%{"path_id" => path_id}, _session, socket) do
    path = Answers.get!(Path, path_id)
    state = %State{}

    {:ok, assign(socket, state: state, path: path), temporary_assigns: [path: nil]}
  end

  def handle_info({:perform_action, {component_id, action, params}}, socket) do
    send_update(PathComponent, id: component_id, action: action, params: params)
    {:noreply, socket}
  end

  def handle_info({:delay_action, message}, %{assigns: %{state: state}} = socket) do
    if state.timer_ref do
      Process.cancel_timer(state.timer_ref)
    end

    ref = Process.send_after(self(), {:perform_action, message}, 500)
    state = %State{state | timer_ref: ref}

    {:noreply, assign(socket, :state, state)}
  end

  def render(assigns) do
    Phoenix.View.render(PathsView, "edit_path.html", assigns)
  end
end
