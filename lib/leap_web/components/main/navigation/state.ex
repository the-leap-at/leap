defmodule LeapWeb.Components.Main.Navigation.State do
  @moduledoc """
  Navigation State
  """

  use TypedStruct

  alias __MODULE__
  alias LeapWeb.Components.State, as: StateBehaviour

  @behaviour StateBehaviour

  @typedoc "Navigation state"
  typedstruct do
    field :id, String.t(), enforce: true
    field :module, module(), enforce: true
    field :current_user, User.t(), enforce: true
  end

  @impl StateBehaviour
  def init(%{id: id, current_user: current_user}) do
    state = %State{
      id: id,
      module: LeapWeb.Components.Main.Navigation,
      current_user: current_user
    }

    {:ok, state}
  end

  @impl StateBehaviour
  def commit(_action, _attrs, state) do
    {:ok, state}
  end
end
