defmodule LeapWeb.Components.Main.Post do
  use LeapWeb, :component

  alias LeapWeb.Components.Main.Post.State

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :init} = assigns, socket) do
    mutation = State.init(assigns)
    response(mutation, socket)
  end

  def update(%{action: action, payload: attrs}, %{assigns: %{state: state}} = socket) do
    mutation = State.commit(action, attrs, state)
    response(mutation, socket)
  end

  defp response({:ok, {%State{} = state, {message_type, message}}}, socket) do
    send_notification(state.id, message_type, message)
    {:ok, assign(socket, :state, state)}
  end

  defp response({:ok, %State{} = state}, socket) do
    {:ok, assign(socket, :state, state)}
  end

  defp response({:error, message}, socket) do
    send_notification(socket.assigns.state.id, :danger, message)
    {:ok, socket}
  end

  defp post_behaviour_component(%{post_behaviour: :show_post} = state, socket) do
    live_component(socket, LeapWeb.Components.Main.Post.Show,
      id: "show_post_" <> to_string(state.post.id),
      action: :init,
      state: state
    )
  end

  defp post_behaviour_component(%{post_behaviour: :edit_post} = state, socket) do
    live_component(socket, LeapWeb.Components.Main.Post.Edit,
      id: "edit_post_" <> to_string(state.post.id),
      action: :init,
      state: state
    )
  end
end
