defmodule LeapWeb.Components.Main.Post.Show do
  @moduledoc """
  - Shows post
  """
  use LeapWeb, :component

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :init} = assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("edit_post", _params, %{assigns: %{state: state}} = socket) do
    send_to_main(:edit_post, %{}, state)

    {:noreply, socket}
  end

  defp updates_component(id, state, socket) do
    live_component(socket, LeapWeb.Components.Main.Post.Show.Updates,
      id: "#{id}_update",
      action: :init,
      state: state
    )
  end
end
