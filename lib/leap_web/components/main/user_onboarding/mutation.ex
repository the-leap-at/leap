defmodule LeapWeb.Components.Main.UserOnboarding.Mutation do
  @moduledoc """
  Mutations for UserOnboarding
  """

  alias Leap.Accounts
  alias Leap.Accounts.Schema.User
  alias Leap.Group
  alias Leap.Group.Schema.Category

  alias LeapWeb.Components.Main.UserOnboarding.State

  defguard is_present(value) when is_binary(value) and bit_size(value) > 0

  @spec init(args :: map()) :: State.t()
  def init(%{id: id, module: module, current_user: current_user}) do
    current_user = with_preloads(current_user)
    changeset = Accounts.change_user(current_user)
    categories = Group.all(Category)

    %State{
      id: id,
      module: module,
      current_user: current_user,
      user_changeset: changeset,
      categories: remaining_categories(categories, current_user)
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
    user = Accounts.transition_user_state_to!(state.current_user, user_state)

    %State{
      state
      | current_user: user,
        user_changeset: Accounts.change_user(user)
    }
  end

  @spec search_category(args :: map(), State.t()) :: State.t()
  def search_category(%{term: term}, state) when is_present(term) do
    categories = Group.search_category(term)
    %State{state | categories: remaining_categories(categories, state.current_user)}
  end

  def search_category(_args, state) do
    categories = Group.all(Category)
    %State{state | categories: remaining_categories(categories, state.current_user)}
  end

  @spec add_user_fav_category(args :: map(), State.t()) :: State.t()
  def add_user_fav_category(args, state) do
    Group.add_user_fav_category!(args)
    categories = Group.all(Category)
    current_user = with_preloads(state.current_user)

    %State{
      state
      | current_user: current_user,
        categories: remaining_categories(categories, current_user)
    }
  end

  @spec remove_user_fav_category(args :: map(), State.t()) :: State.t()
  def remove_user_fav_category(args, state) do
    Group.remove_user_fav_category!(args)
    categories = Group.all(Category)
    current_user = with_preloads(state.current_user)

    %State{
      state
      | current_user: current_user,
        categories: remaining_categories(categories, current_user)
    }
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
