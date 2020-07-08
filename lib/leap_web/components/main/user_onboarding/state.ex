defmodule LeapWeb.Components.Main.UserOnboarding.State do
  @moduledoc """
  UserOnboarding State
  """
  use TypedStruct

  alias __MODULE__
  alias LeapWeb.Components.State, as: StateBehaviour

  alias Leap.Accounts
  alias Leap.Accounts.Schema.User
  alias Leap.Group
  alias Leap.Group.Schema.Category

  @behaviour StateBehaviour

  @typedoc "UserOnboarding state"
  typedstruct do
    field :id, String.t(), enforce: true
    field :module, module(), enforce: true
    field :current_user, User.t(), enforce: true
    field :user_changeset, Ecto.Changeset.t(User.t())
    field :categories, [Category.t()], default: []
  end

  defguard is_present(value) when is_binary(value) and bit_size(value) > 0

  @impl StateBehaviour
  def init(%{id: id, current_user: current_user}) do
    current_user = with_preloads(current_user)
    changeset = Accounts.change_user(current_user)
    categories = Group.all(Category)

    state = %State{
      id: id,
      module: LeapWeb.Components.Main.UserOnboarding,
      current_user: current_user,
      user_changeset: changeset,
      categories: remaining_categories(categories, current_user)
    }

    {:ok, state}
  end

  @impl StateBehaviour
  def commit(:update_user, user_params, state) do
    case Accounts.update_user(state.current_user, user_params) do
      {:ok, user} ->
        state = %State{
          state
          | current_user: user,
            user_changeset: Accounts.change_user(user)
        }

        {:ok, state}

      {:error, changeset} ->
        state = %State{state | user_changeset: changeset}
        {:ok, {state, {:warning, "Something went wrong"}}}
    end
  end

  def commit(:transition_user_state, user_state, state) do
    IO.inspect("set state")
    IO.inspect(user_state)
    user = Accounts.transition_user_state_to!(state.current_user, user_state)

    state = %State{
      state
      | current_user: user,
        user_changeset: Accounts.change_user(user)
    }

    {:ok, state}
  end

  def commit(:search_category, term, state) when is_present(term) do
    categories = Group.search_category(term)
    state = %State{state | categories: remaining_categories(categories, state.current_user)}
    {:ok, state}
  end

  def commit(:search_category, _term, state) do
    categories = Group.all(Category)
    state = %State{state | categories: remaining_categories(categories, state.current_user)}
    {:ok, state}
  end

  def commit(:add_user_fav_category, args, state) do
    Group.add_user_fav_category!(args)
    categories = Group.all(Category)
    current_user = with_preloads(state.current_user)

    state = %State{
      state
      | current_user: current_user,
        categories: remaining_categories(categories, current_user)
    }

    {:ok, state}
  end

  def commit(:remove_user_fav_category, args, state) do
    Group.remove_user_fav_category!(args)
    categories = Group.all(Category)
    current_user = with_preloads(state.current_user)

    state = %State{
      state
      | current_user: current_user,
        categories: remaining_categories(categories, current_user)
    }

    {:ok, state}
  end

  defp with_preloads(%User{} = user) do
    Accounts.with_preloads(user, [:fav_categories], force: true)
  end

  defp remaining_categories(categories, current_user) do
    user_categories_ids = Enum.map(current_user.fav_categories, & &1.id)

    categories
    |> Enum.reject(&(&1.id in user_categories_ids))
  end
end
