defmodule LeapWeb.Components.Main.UserOnboarding.Finish do
  use LeapWeb, :component

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :init} = assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
