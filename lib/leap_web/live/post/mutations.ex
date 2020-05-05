defmodule LeapWeb.Live.Post.Mutations do
  @moduledoc "mutations for PostLive"

  alias LeapWeb.PostLive.State

  alias Leap.Content
  alias Leap.Content.Schema.Post

  @spec init(args :: map()) :: State.t()
  def init(%{post_id: post_id}) do
    post = get_post(post_id)
    changeset = Content.change_post(post)

    %State{
      post: post,
      post_changeset: changeset,
      post_component: LeapWeb.Components.ShowPost
    }
  end

  @spec update(atom(), any(), State.t()) :: State.t()
  def update(key, value, state) do
    Map.replace!(state, key, value)
  end

  @spec publish_post(args :: map(), State.t()) :: State.t()
  def publish_post(%{params: post_params}, state) do
    case Content.publish_post(state.post, post_params) do
      {:ok, post} ->
        %State{
          state
          | post: post,
            post_changeset: Content.change_post(post)
        }

      {:error, changeset} ->
        %State{state | post_changeset: changeset}
    end
  end

  defp get_post(post_id) do
    Post
    |> Content.get!(post_id)
    |> Content.with_preloads([:category])
  end
end
