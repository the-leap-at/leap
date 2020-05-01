defmodule Leap.Content.Posts do
  @moduledoc """
  Functions specific to Posts.
  The functions that are not exposed throught Content (defdelegate) are only context internal
  """
  alias Leap.Repo
  alias Leap.Content.Schema.Post
  alias Leap.Group.Schema.Category

  @editable_state [:draft, :published]
  @publishable_state [:draft, :published]

  @doc "Function used by Machinery to persist the state update"
  @spec update_state!(Post.t(), next_state :: Post.StateEnum.t()) :: Post.t()
  def update_state!(post, next_state) do
    post
    |> Post.changeset_state_transition(%{state: next_state})
    |> Repo.update!()
  end

  @doc "Machinery wrapper that converts errors to changest"
  @spec transition_state_to(Post.t(), next_state :: atom()) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  def transition_state_to(%Post{} = post, next_state) when is_atom(next_state) do
    case Machinery.transition_to(post, Post.StateMachine, next_state) do
      {:ok, post} ->
        {:ok, post}

      {:error, cause} ->
        changeset = Post.changeset_state_transition_error(post, %{state: next_state}, cause)
        {:error, changeset}
    end
  end

  @spec update(Post.t(), attrs :: map()) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  @doc "when updating a new post, it transitions to draft state"
  def update(%Post{state: :new} = post, attrs) do
    with {:ok, post} = transition_state_to(post, :draft) do
      update(post, attrs)
    end
  end

  def update(%Post{state: state} = post, attrs) when state in @editable_state do
    post
    |> Post.changeset_update(attrs)
    |> Repo.update()
  end

  @spec publish(Post.t(), attrs :: map()) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  def publish(%Post{state: state} = post, attrs) when state in @publishable_state do
    with changeset = Post.changeset_publish(post, attrs),
         {:ok, post} <- Repo.update(changeset),
         {:ok, post} <- transition_state_to_published(post) do
      {:ok, post}
    end
  end

  defp transition_state_to_published(%Post{state: :published} = post), do: {:ok, post}
  defp transition_state_to_published(post), do: transition_state_to(post, :published)

  def category(%Post{} = post, %Category{} = category) do
    post
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:category, category)
    |> Repo.update()
  end

  @spec validate_publish(Post.t()) :: Ecto.Changeset.t(Post.t())
  def validate_publish(%Post{} = post, attrs \\ %{}) do
    post
    |> Post.changeset_publish(attrs)
    |> Map.put(:action, :insert)
  end

  @spec change(Post.t()) :: Ecto.Changeset.t(Post.t())
  def change(%Post{} = post, attrs \\ %{}) do
    Post.changeset_update(post, attrs)
  end
end
