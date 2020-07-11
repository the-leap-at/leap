defmodule LeapWeb.Components.Container.Onboarding do
  use LeapWeb, :component

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :init} = assigns, socket) do
    user_onboarding_component =
      live_component(socket, LeapWeb.Components.Main.UserOnboarding,
        id: "onboarding_user_#{to_string(assigns.current_user.id)}",
        action: :init,
        current_user: assigns.current_user
      )

    assigns = Map.merge(assigns, %{user_onboarding_component: user_onboarding_component})
    {:ok, assign(socket, assigns)}
  end
end
