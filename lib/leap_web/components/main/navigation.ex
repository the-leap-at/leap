defmodule LeapWeb.Components.Main.Navigation do
  use LeapWeb, :component
  use TypedStruct

  alias LeapWeb.Components.Main.Navigation.Mutation

  defmodule State do
    @moduledoc false

    @typedoc "Navigation state"
    typedstruct do
      field :id, String.t(), enforce: true
      field :module, module(), enforce: true
      field :current_user, User.t(), enforce: true
    end
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :init} = assigns, socket) do
    assigns = Map.merge(assigns, %{module: __MODULE__})
    state = Mutation.init(assigns)
    {:ok, assign(socket, :state, state)}
  end

  def handle_event("disconnect", _params, %{assigns: %{state: state}} = socket) do
    LeapWeb.Endpoint.broadcast(
      "users_socket:#{state.current_user.id}",
      "disconnect",
      %{}
    )

    {:noreply, socket}
  end
end
