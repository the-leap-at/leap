defmodule LeapWeb.Components.Container.Notifications do
  use LeapWeb, :component

  def mount(socket) do
    {:ok, socket, temporary_assigns: [notifications: []]}
  end

  def update(%{action: :init} = assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def update(%{action: :notify, payload: notification}, socket) do
    socket = assign(socket, :notifications, [notification])

    {:ok, socket}
  end

  defp notification_component(%{sender_id: sender_id} = notification, socket) do
    live_component(socket, LeapWeb.Components.Main.Notification,
      id: "notification_#{to_string(sender_id)}",
      action: :init,
      notification: notification
    )
  end
end
