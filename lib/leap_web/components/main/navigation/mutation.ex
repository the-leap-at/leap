defmodule LeapWeb.Components.Main.Navigation.Mutation do
  @moduledoc """
  Mutations for Navigation
  """

  alias LeapWeb.Components.Main.Navigation.State

  @spec init(args :: map()) :: State.t()
  def init(%{id: id, module: module, current_user: current_user}) do
    %State{
      id: id,
      module: module,
      current_user: current_user
    }
  end
end
