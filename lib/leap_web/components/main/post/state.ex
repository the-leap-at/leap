defmodule LeapWeb.Components.Main.Post.State do
  @moduledoc """
  Mutations for Post
  """

  use TypedStruct

  alias __MODULE__
  alias LeapWeb.Components.State, as: StateBehaviour

  alias Leap.Content
  alias Leap.Content.Schema.Post
  alias Leap.Group
  alias Leap.Group.Schema.Category
  alias Leap.Accounts.Schema.User

  @behaviour StateBehaviour

  @typedoc "Post state"
  typedstruct do
    field :id, String.t(), enforce: true
    field :module, module(), enforce: true
    field :current_user, User.t()
    field :post, Post.t(), enforce: true
    field :post_changeset, Ecto.Changeset.t(Post.t())
    field :post_behaviour, atom(), default: :show_post, enforce: true
    field :categories, [Category.t()], default: []
  end

  defguard is_present(value) when is_binary(value) and bit_size(value) > 0

  @impl StateBehaviour
  def init(%{id: id, post: post, current_user: current_user}) do
    changeset = Content.change_post(post)

    state = %State{
      id: id,
      module: LeapWeb.Components.Main.Post,
      current_user: current_user,
      post: post,
      post_changeset: changeset,
      post_behaviour: post_behaviour(post),
      categories: Group.all(Category)
    }

    {:ok, state}
  end

  @impl StateBehaviour
  def commit(:update_post, post_params, state) do
    case Content.update_post(state.current_user, state.post, post_params) do
      {:ok, post} ->
        state = %State{
          state
          | post: with_preloads(post),
            post_changeset: Content.change_post(post)
        }

        {:ok, state}

      {:error, %Ecto.Changeset{} = changeset} ->
        state = %State{state | post_changeset: changeset}
        {:ok, state}

      {:error, message} ->
        {:error, message}
    end
  end

  def commit(:update_post_category, post_params, state) do
    post = Content.update_post!(state.current_user, state.post, post_params)

    state = %State{
      state
      | post: with_preloads(post)
    }

    {:ok, state}
  end

  def commit(:validate_publish_post, post_params, state) do
    changeset = Content.validate_publish_post(state.post, post_params)

    state = %State{state | post_changeset: changeset}
    {:ok, state}
  end

  def commit(:publish_post, post_params, state) do
    case Content.publish_post(state.current_user, state.post, post_params) do
      {:ok, post} ->
        state = %State{
          state
          | post: with_preloads(post),
            post_changeset: Content.change_post(post),
            post_behaviour: :show_post
        }

        {:ok, state}

      {:error, %Ecto.Changeset{} = changeset} ->
        state = %State{state | post_changeset: changeset}
        {:ok, {state, {:danger, "Error publishing post"}}}

      {:error, message} ->
        {:error, message}
    end
  end

  def commit(:search_category, term, state) when is_present(term) do
    categories = Group.search_category(term)
    state = %State{state | categories: categories}
    {:ok, state}
  end

  def commit(:search_category, _term, state) do
    categories = Group.all(Category)
    state = %State{state | categories: categories}
    {:ok, state}
  end

  def commit(:change_post_behaviour, post_behaviour, state) do
    state = %State{
      state
      | post_behaviour: post_behaviour,
        post_changeset: Content.change_post(state.post)
    }

    {:ok, state}
  end

  ######

  defp with_preloads(%Post{} = post) do
    Content.with_preloads(post, [:category], force: true)
  end

  defp post_behaviour(%Post{state: :new}), do: :edit_post
  defp post_behaviour(%Post{state: :draft}), do: :edit_post
  defp post_behaviour(%Post{state: :published}), do: :show_post
end
