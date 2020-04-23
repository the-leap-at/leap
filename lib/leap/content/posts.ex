defmodule Leap.Content.Posts do
  @moduledoc """
  Functions specific to Posts.
  The functions that are not exposed throught Content (defdelegate) are only context internal

  """
  alias Leap.Repo
  alias Leap.Content.Schema.Post

  @editable_state [:draft, :published]
  @publishable_state [:draft, :published]

  @doc "Function used by Machinery to persist the state update"
  @spec update_post_state!(Post.t(), next_state :: Post.StateEnum.t()) :: Post.t()
  def update_post_state!(post, next_state) do
    post
    |> Post.changeset_state_transition(%{state: next_state})
    |> Repo.update!()
  end

  @doc "Machinery wrapper that converts errors to changest"
  @spec transition_state_to(Post.t(), Post.StateEnum.t()) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  def transition_state_to(post, next_state) do
    case Machinery.transition_to(post, Post.StateMachine, next_state) do
      {:ok, post} ->
        {:ok, post}

      {:error, cause} ->
        changeset = Post.changeset_state_transition_error(post, %{state: next_state}, cause)
        {:error, changeset}
    end
  end

  @spec update_post(Post.t(), attrs :: map()) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  @doc "when updating a new post, it transitions to draft state"
  def update_post(%Post{state: :new} = post, attrs) do
    with {:ok, post} = transition_state_to(post, :draft) do
      update_post(post, attrs)
    end
  end

  def update_post(%Post{state: state} = post, attrs) when state in @editable_state do
    post
    |> Post.changeset_update(attrs)
    |> Repo.update()
  end

  @spec publish_post(Post.t(), attrs :: map()) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  def publish_post(%Post{state: state} = post, attrs) when state in @publishable_state do
    with changeset = Post.changeset_publish(post, attrs),
         {:ok, post} <- Repo.update(changeset),
         {:ok, post} <- transition_state_to_published(post, :published) do
      {:ok, post}
    end
  end

  defp transition_state_to_published(%Post{state: :published} = post, :published), do: {:ok, post}
  defp transition_state_to_published(post, :published), do: transition_state_to(post, :published)

  @spec validate_publish_post(Post.t()) :: Ecto.Changeset.t(Post.t())
  def validate_publish_post(%Post{} = post, attrs \\ %{}) do
    post
    |> Post.changeset_publish(attrs)
    |> Map.put(:action, :insert)
  end

  @spec change_post(Post.t()) :: Ecto.Changeset.t(Post.t())
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset_update(post, attrs)
  end
end
