defmodule LeapWeb.Components.Main.Notification do
  use LeapWeb, :component
  use TypedStruct

  alias LeapWeb.Components.Main.Notification.State

  @display_timeout 5000

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :init} = assigns, socket) do
    mutation = {:ok, state} = State.init(assigns)
    dismiss_notification(state)

    response(mutation, socket)
  end

  def update(%{action: action, payload: attrs}, %{assigns: %{state: state}} = socket) do
    mutation = State.commit(action, attrs, state)
    response(mutation, socket)
  end

  def handle_event("dismiss", _params, %{assigns: %{state: state}} = socket) do
    state = %State{state | display: false}

    {:noreply, assign(socket, :state, state)}
  end

  defp response({:ok, %State{} = state}, socket) do
    {:ok, assign(socket, :state, state)}
  end

  # ignoring bad notifications
  defp response(_mutation, socket) do
    {:ok, socket}
  end

  defp dismiss_notification(%State{display_timeout: :none}), do: nil

  defp dismiss_notification(%State{display_timeout: :default} = state),
    do: delay_send_to_main(@display_timeout, :dismiss, %{}, state)

  defp dismiss_notification(%State{display_timeout: timeout} = state) when is_integer(timeout),
    do: delay_send_to_main(timeout, :dismiss, %{}, state)

  defp dismiss_notification(state),
    do: delay_send_to_main(@display_timeout, :dismiss, %{}, state)
end
