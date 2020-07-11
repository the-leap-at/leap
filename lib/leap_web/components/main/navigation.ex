defmodule LeapWeb.Components.Main.Navigation do
  use LeapWeb, :component
  use TypedStruct

  alias LeapWeb.Components.Main.Navigation.State

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :init} = assigns, socket) do
    mutation = State.init(assigns)
    response(mutation, socket)
  end

  def handle_event("disconnect", _params, %{assigns: %{state: state}} = socket) do
    LeapWeb.Endpoint.broadcast(
      "users_socket:#{state.current_user.id}",
      "disconnect",
      %{}
    )

    {:noreply, socket}
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
end
