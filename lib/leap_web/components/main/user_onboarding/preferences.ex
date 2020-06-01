defmodule LeapWeb.Components.Main.UserOnboarding.Preferences do
  use LeapWeb, :component

  alias Leap.Group.Schema.Category

  @delay 500

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    category_form = search_category_form(assigns.id)

    assigns = Map.merge(assigns, %{category_form: category_form})

    {:ok, assign(socket, assigns)}
  end

  def handle_event(
        "search_category",
        %{"category" => %{"query_term" => term}},
        %{assigns: %{state: state}} = socket
      ) do
    delay_send_to_main(@delay, :search_category, term, state)
    {:noreply, socket}
  end

  def handle_event(
        "add_category",
        %{"category_id" => category_id},
        %{assigns: %{state: state}} = socket
      ) do
    send_to_main(
      :add_user_fav_category,
      %{category_id: String.to_integer(category_id), user_id: state.current_user.id},
      state
    )

    {:noreply, socket}
  end

  def handle_event(
        "remove_category",
        %{"category_id" => category_id},
        %{assigns: %{state: state}} = socket
      ) do
    send_to_main(
      :remove_user_fav_category,
      %{category_id: String.to_integer(category_id), user_id: state.current_user.id},
      state
    )

    {:noreply, socket}
  end

  def handle_event("next", _params, %{assigns: %{state: state}} = socket) do
    send_to_main(:transition_user_state, :onboarded, state)

    # {:noreply, push_patch(socket, to: "/")}
    {:noreply, socket}
  end

  def handle_event("prevent_submit", _params, socket) do
    {:noreply, socket}
  end

  defp search_category_form(component_id) do
    form_for(:category, "#",
      phx_change: "search_category",
      phx_submit: "prevent_submit",
      phx_target: "#" <> component_id
    )
  end
end
