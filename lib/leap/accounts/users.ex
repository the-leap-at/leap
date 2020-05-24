defmodule Leap.Accounts.Users do
  @moduledoc """
  Functions specific to Users.
  The functions that are not exposed throught the context (defdelegate) are only context internal
  """

  alias Leap.Repo
  alias Leap.Accounts.Schema.User

  def fetch_user(email) do
    case Repo.get_by(User, email: email) do
      %User{} = user -> {:ok, user}
      result -> {:error, result}
    end
  end

  @doc "Function used by Machinery to persist the state update"
  @spec update_state!(User.t(), next_state :: User.StateEnum.t()) :: User.t()
  def update_state!(%User{} = user, next_state) do
    user
    |> User.changeset_state_transition(%{state: next_state})
    |> Repo.update!()
  end

  @doc "Machinery wrapper that converts errors to changest"
  @spec transition_state_to(User.t(), next_state :: atom()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t(User.t())}
  def transition_state_to(%User{} = user, next_state) when is_atom(next_state) do
    case Machinery.transition_to(user, User.StateMachine, next_state) do
      {:ok, user} ->
        {:ok, user}

      {:error, cause} ->
        changeset = User.changeset_state_transition_error(user, %{state: next_state}, cause)
        {:error, changeset}
    end
  end
end
