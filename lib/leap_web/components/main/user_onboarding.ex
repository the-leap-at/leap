defmodule LeapWeb.Components.Main.UserOnboarding do
  use LeapWeb, :component

  alias LeapWeb.Components.Main.UserOnboarding.State
  alias Leap.Accounts.Schema.User

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

  defp onboarding_step_component(%{current_user: %User{state: :authenticated}} = state, socket) do
    live_component(socket, LeapWeb.Components.Main.UserOnboarding.DisplayName,
      id: "display_name_" <> state.id,
      action: :init,
      state: state
    )
  end

  defp onboarding_step_component(%{current_user: %User{state: :display_name_set}} = state, socket) do
    live_component(socket, LeapWeb.Components.Main.UserOnboarding.Preferences,
      id: "preferences_" <> state.id,
      action: :init,
      state: state
    )
  end

  defp onboarding_step_component(%{current_user: %User{state: :onboarded}} = state, socket) do
    live_component(socket, LeapWeb.Components.Main.UserOnboarding.Finish,
      id: "finish_" <> state.id,
      action: :init,
      state: state
    )
  end
end
