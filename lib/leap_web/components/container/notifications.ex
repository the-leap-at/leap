defmodule LeapWeb.Components.Container.Notifications do
  @moduledoc """
  Notifications Container
  Handles notifications sent from all components.
  But also displays custom notifications, such as a sign in reminder, or news. Those are added to the notifications list in the update init
  """
  use LeapWeb, :component

  def mount(socket) do
    {:ok, socket, temporary_assigns: [notifications: []]}
  end

  def update(%{action: :init} = assigns, socket) do
    notifications =
      []
      |> sign_in_notification(assigns)

    socket = assign(socket, :notifications, notifications)
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

  defp sign_in_notification(notifications, %{current_user: nil}) do
    notification = %{
      type: :info,
      message: sign_in_notification_message(),
      display_timeout: :none,
      sender_id: "sign_in"
    }

    [notification | notifications]
  end

  defp sign_in_notification(notifications, _assigns), do: notifications

  # TODO : need to make the notification html generation nicer
  # Tried with the ~L sigil, but the content renders on the parent page also
  defp sign_in_notification_message do
    sign_in_link = link("Sign in", to: "/session/new") |> safe_to_string()

    """
    #{sign_in_link} to ask questions, respond, comment or vote
    """
  end
end
