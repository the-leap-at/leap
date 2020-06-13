defmodule LeapWeb.Components.Container.Navbar do
  use LeapWeb, :component

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    navigation_component =
      live_component(socket, LeapWeb.Components.Main.Navigation,
        id: "navigation",
        current_user: assigns.current_user,
        action: :init
      )

    assigns = Map.merge(assigns, %{navigation_component: navigation_component})
    {:ok, assign(socket, assigns)}
  end
end
