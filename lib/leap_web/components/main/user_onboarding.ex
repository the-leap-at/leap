defmodule LeapWeb.Components.Main.UserOnboarding do
  use LeapWeb, :component
  use TypedStruct

  alias LeapWeb.Components.Main.UserOnboarding.Mutation
  alias Leap.Accounts.Schema.User

  defmodule State do
    @moduledoc false

    @typedoc "UserOnboarding state"
    typedstruct do
      field :id, String.t(), enforce: true
      field :module, module(), enforce: true
      field :current_user, User.t(), enforce: true
      field :user_changeset, Ecto.Changeset.t(User.t())
      field :categories, [Category.t()], default: []
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

  def update(%{action: :update_user, payload: user_params}, %{assigns: %{state: state}} = socket) do
    state = Mutation.update_user(%{params: user_params}, state)

    {:ok, assign(socket, :state, state)}
  end

  def update(
        %{action: :transition_user_state, payload: user_state},
        %{assigns: %{state: state}} = socket
      ) do
    state = Mutation.transition_user_state(user_state, state)
    {:ok, assign(socket, :state, state)}
  end

  def update(
        %{action: :search_category, payload: search_term},
        %{assigns: %{state: state}} = socket
      ) do
    state = Mutation.search_category(%{term: search_term}, state)

    {:ok, assign(socket, :state, state)}
  end

  def update(
        %{action: :add_user_fav_category, payload: params},
        %{assigns: %{state: state}} = socket
      ) do
    state = Mutation.add_user_fav_category(params, state)

    {:ok, assign(socket, :state, state)}
  end

  def update(
        %{action: :remove_user_fav_category, payload: params},
        %{assigns: %{state: state}} = socket
      ) do
    state = Mutation.remove_user_fav_category(params, state)

    {:ok, assign(socket, :state, state)}
  end

  defp onboarding_step_component(%{current_user: %User{state: :authenticated}} = state, socket) do
    live_component(socket, LeapWeb.Components.Main.UserOnboarding.DisplayName,
      id: "display_name_" <> state.id,
      action: :init,
      state: state
    )
  end

  defp onboarding_step_component(%{current_user: %User{state: :display_name_set}} = state, socket) do
    live_component(socket, LeapWeb.Components.Main.UserOnboarding.Preferences,
      id: "preferences_" <> state.id,
      action: :init,
      state: state
    )
  end
end
