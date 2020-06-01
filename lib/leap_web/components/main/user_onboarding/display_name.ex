defmodule LeapWeb.Components.Main.UserOnboarding.DisplayName do
  use LeapWeb, :component

  @delay 500

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    display_name_form = display_name_form(assigns.id, assigns.state.user_changeset)
    assigns = Map.merge(assigns, %{display_name_form: display_name_form})
    {:ok, assign(socket, assigns)}
  end

  def handle_event("update_user", %{"user" => user_params}, %{assigns: %{state: state}} = socket) do
    delay_send_to_main(@delay, :update_user, user_params, state)

    {:noreply, socket}
  end

  def handle_event("next", _params, %{assigns: %{state: state}} = socket) do
    if allow_next?(state) do
      send_to_main(:transition_user_state, :display_name_set, state)
    end

    {:noreply, socket}
  end

  defp display_name_form(component_id, %Ecto.Changeset{} = changeset) do
    form_for(changeset, "#", phx_change: "update_user", phx_target: "#" <> component_id)
  end

  defp allow_next?(state) do
    state.current_user.display_name && state.user_changeset.valid?
  end
end
