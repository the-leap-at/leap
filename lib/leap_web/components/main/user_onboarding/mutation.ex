defmodule LeapWeb.Components.Main.UserOnboarding.Mutation do
  @moduledoc """
  Mutations for UserOnboarding
  """

  alias Leap.Accounts
  alias LeapWeb.Components.Main.UserOnboarding.State

  @spec init(args :: map()) :: State.t()
  def init(%{id: id, module: module, current_user: current_user}) do
    changeset = Accounts.change_user(current_user)

    %State{
      id: id,
      module: module,
      current_user: current_user,
      user_changeset: changeset
    }
  end

  @spec update(atom(), any(), State.t()) :: State.t()
  def update(key, value, state) do
    Map.replace!(state, key, value)
  end

  @spec update_user(map(), State.t()) :: State.t()
  def update_user(%{params: user_params}, state) do
    case Accounts.update_user(state.current_user, user_params) do
      {:ok, user} ->
        %State{
          state
          | current_user: user,
            user_changeset: Accounts.change_user(user)
        }

      {:error, changeset} ->
        %State{state | user_changeset: changeset}
    end
  end

  @spec transition_user_state(atom(), State.t()) :: State.t()
  def transition_user_state(user_state, state) do
    case Accounts.transition_user_state_to(state.current_user, user_state) do
      {:ok, user} ->
        %State{
          state
          | current_user: user,
            user_changeset: Accounts.change_user(user)
        }

      {:error, changeset} ->
        %State{state | user_changeset: changeset}
    end
  end
end
