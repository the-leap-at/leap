defmodule LeapWeb.Components.Main.UserOnboarding.DisplayName do
  use LeapWeb, :component

  @delay 1000

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

  defp display_name_form(component_id, %Ecto.Changeset{} = changeset) do
    form_for(changeset, "#", phx_change: "update_user", phx_target: "#" <> component_id)
  end
end
