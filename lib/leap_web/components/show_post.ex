defmodule LeapWeb.Components.ShowPost do
  @moduledoc """
  - Shows posts
  """
  use LeapWeb, :component
  use TypedStruct

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  defp updates_component(id, state, socket) do
    live_component(socket, LeapWeb.Components.ShowPost.Updates,
      id: "#{id}_update",
      state: state
    )
  end
end
