defmodule LeapWeb.Components.EditPost.EditCategory do
  @moduledoc """
  - Edit posts category
  - The categories are predefined and added in the DB with a migration (at least for now)
  """
  use LeapWeb, :component

  alias Leap.Group.Schema.Category

  @debounce 500

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    value = assigns.state.post.category && assigns.state.post.category.name
    category_form = search_category_form(assigns.id)

    assigns =
      Map.merge(assigns, %{category_form: category_form, value: value, debounce: @debounce})

    {:ok, assign(socket, assigns)}
  end

  def handle_event(
        "search_category",
        %{"category" => %{"query_term" => term}},
        socket
      ) do
    send(self(), {:search_category, term})
    {:noreply, socket}
  end

  def handle_event(
        "update_category",
        %{"category_id" => category_id},
        socket
      ) do
    send(self(), {:update_post, %{category_id: category_id}})

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
