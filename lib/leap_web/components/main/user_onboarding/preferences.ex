defmodule LeapWeb.Components.Main.UserOnboarding.Preferences do
  use LeapWeb, :component

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
