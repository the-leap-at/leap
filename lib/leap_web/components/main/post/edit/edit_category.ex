defmodule LeapWeb.Components.Main.Post.Edit.EditCategory do
  @moduledoc """
  - Edit posts category
  - The categories are predefined and added in the DB with a migration (at least for now)
  """
  use LeapWeb, :component

  alias Leap.Group.Schema.Category

  @delay 500

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :init} = assigns, socket) do
    value = assigns.state.post.category && assigns.state.post.category.name
    category_form = search_category_form(assigns.id)

    assigns = Map.merge(assigns, %{category_form: category_form, value: value})

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
        "update_category",
        %{"category_id" => category_id},
        %{assigns: %{state: state}} = socket
      ) do
    send_to_main(:update_post_category, %{category_id: category_id}, state)

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

  defp category_name(%Category{name: name}), do: name
  defp category_name(_), do: nil
end
