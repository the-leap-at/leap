defmodule LeapWeb.Components.Main.Post.Mutation do
  @moduledoc """
  Mutations for Post
  Need to make distinction between mutations that update the changeset or not
  """

  alias LeapWeb.Components.Main.Post.State

  alias Leap.Content
  alias Leap.Content.Schema.Post
  alias Leap.Group
  alias Leap.Group.Schema.Category

  defguard is_present(value) when is_binary(value) and bit_size(value) > 0

  @spec commit(atom(), any(), State.t()) :: State.t()
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
        {:ok, state}

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
end
