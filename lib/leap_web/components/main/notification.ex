defmodule LeapWeb.Components.Main.Notification do
  use LeapWeb, :component
  use TypedStruct

  @dismiss_delay 5000

  defmodule State do
    @moduledoc false

    @type notification_type() :: :info | :success | :warning | :danger

    @typedoc "Notification state"
    typedstruct do
      field :id, String.t(), enforce: true
      field :module, module(), enforce: true
      field :type, notification_type(), enforce: true
      field :message, String.t(), enforce: true
      field :display, boolean(), default: true
    end
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :init, id: id, notification: notification}, socket) do
    state = %State{
      id: id,
      module: __MODULE__,
      type: notification.type,
      message: notification.message
    }

    delay_send_to_main(@dismiss_delay, :dismiss, %{}, state)

    {:ok, assign(socket, :state, state)}
  end

  def update(%{action: :dismiss}, %{assigns: %{state: state}} = socket) do
    state = %State{state | display: false}

    {:ok, assign(socket, :state, state)}
  end

  def handle_event("dismiss", _params, %{assigns: %{state: state}} = socket) do
    state = %State{state | display: false}

    {:noreply, assign(socket, :state, state)}
  end
end
