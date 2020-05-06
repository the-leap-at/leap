defmodule LeapWeb.Live.Post.Mutations do
  @moduledoc "mutations for PostLive"

  alias LeapWeb.PostLive.State

  alias Leap.Content
  alias Leap.Content.Schema.Post
  alias Leap.Group
  alias Leap.Group.Schema.Category

  defguard is_present(value) when is_binary(value) and bit_size(value) > 0

  @spec init(args :: map()) :: State.t()
  def init(%{post_id: post_id}) do
    post = get_post(post_id)
    changeset = Content.change_post(post)

    %State{
      post: post,
      post_changeset: changeset,
      post_component: LeapWeb.Components.ShowPost,
      categories: Group.all(Category)
    }
  end

  @spec update(atom(), any(), State.t()) :: State.t()
  def update(key, value, state) do
    Map.replace!(state, key, value)
  end

  @spec update_post(args :: map(), State.t()) :: State.t()
  def update_post(%{params: post_params}, state) do
    case Content.update_post(state.post, post_params) do
      {:ok, post} ->
        %State{
          state
          | post: with_preloads(post)
        }

      {:error, changeset} ->
        %State{state | post_changeset: changeset}
    end
  end

  @spec validate_publish_post(args :: map(), State.t()) :: State.t()
  def validate_publish_post(%{params: post_params}, state) do
    changeset = Content.validate_publish_post(state.post, post_params)

    %State{state | post_changeset: changeset}
  end

  @spec publish_post(args :: map(), State.t()) :: State.t()
  def publish_post(%{params: post_params}, state) do
    case Content.publish_post(state.post, post_params) do
      {:ok, post} ->
        %State{
          state
          | post: with_preloads(post)
        }

      {:error, changeset} ->
        %State{state | post_changeset: changeset}
    end
  end

  @spec search_category(args :: map(), State.t()) :: State.t()
  def search_category(%{term: term}, state) when is_present(term) do
    categories = Group.search_category(term)
    %State{state | categories: categories}
  end

  def search_category(_args, state) do
    categories = Group.all(Category)
    %State{state | categories: categories}
  end

  defp get_post(post_id) do
    Post
    |> Content.get!(post_id)
    |> Content.with_preloads([:category])
  end

  defp with_preloads(%Post{} = post) do
    Content.with_preloads(post, [:category], force: true)
  end
end
