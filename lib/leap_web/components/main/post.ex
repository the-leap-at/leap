defmodule LeapWeb.Components.Main.Post do
  use LeapWeb, :component
  use TypedStruct

  alias LeapWeb.Components.Main.Post.Mutation

  defmodule State do
    @moduledoc false

    @typedoc "Post state"
    typedstruct do
      field :id, Sting.t(), enforce: true
      field :module, module(), enforce: true
      field :post, Post.t(), enforce: true
      field :post_changeset, Ecto.Changeset.t(Post.t())
      field :post_behaviour, atom(), default: :show_post, enforce: true
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

  def update(
        %{action: :update_post, payload: post_params},
        %{assigns: %{state: state}} = socket
      ) do
    state = Mutation.update_post(%{params: post_params}, state)

    {:ok, assign(socket, :state, state)}
  end

  def update(
        %{action: :validate_publish_post, payload: post_params},
        %{assigns: %{state: state}} = socket
      ) do
    state = Mutation.validate_publish_post(%{params: post_params}, state)

    {:ok, assign(socket, :state, state)}
  end

  def update(
        %{action: :publish_post, payload: post_params},
        %{assigns: %{state: state}} = socket
      ) do
    state = Mutation.publish_post(%{params: post_params}, state)

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
        %{action: :show_post},
        %{assigns: %{state: state}} = socket
      ) do
    state = Mutation.update(:post_behaviour, :show_post, state)

    {:ok, assign(socket, :state, state)}
  end

  def update(
        %{action: :edit_post},
        %{assigns: %{state: state}} = socket
      ) do
    state = Mutation.update(:post_behaviour, :edit_post, state)

    {:ok, assign(socket, :state, state)}
  end

  defp post_behaviour_component(%{post_behaviour: :show_post} = state, socket) do
    live_component(socket, LeapWeb.Components.Main.Post.Show,
      id: "show_post_" <> to_string(state.post.id),
      state: state
    )
  end

  defp post_behaviour_component(%{post_behaviour: :edit_post} = state, socket) do
    live_component(socket, LeapWeb.Components.Main.Post.Edit,
      id: "edit_post_" <> to_string(state.post.id),
      state: state
    )
  end
end
