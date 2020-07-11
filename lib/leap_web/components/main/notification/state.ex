defmodule LeapWeb.Components.Main.Notification.State do
  @moduledoc """
  Notification State
  """

  use TypedStruct

  alias __MODULE__
  alias LeapWeb.Components.State, as: StateBehaviour

  @behaviour StateBehaviour

  @type notification_type() :: :info | :success | :warning | :danger

  @typedoc "Notification state"
  typedstruct do
    field :id, String.t(), enforce: true
    field :module, module(), enforce: true
    field :type, notification_type(), enforce: true
    field :message, String.t(), enforce: true
    field :display, boolean(), default: true
    field :display_timeout, :default | :none | integer(), enforce: true
  end

  @impl StateBehaviour
  def init(%{id: id, notification: notification}) do
    state = %State{
      id: id,
      module: LeapWeb.Components.Main.Notification,
      type: notification.type,
      message: notification.message,
      display_timeout: notification.display_timeout
    }

    {:ok, state}
  end

  @impl StateBehaviour
  def commit(:dismiss, _attrs, state) do
    state = %State{state | display: false}
    {:ok, state}
  end
end
