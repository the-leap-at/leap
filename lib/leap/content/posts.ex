defmodule Leap.Content.Posts do
  @moduledoc """
  Functions specific to Posts.
  The functions that are not exposed throught Answers (defdelegate) are only context internal

  """
  alias Leap.Repo
  alias Leap.Content.Schema.Post

  @editable_state [:draft, :published]
  @publishable_state [:draft, :published]

  @doc "Function used by Machinery to persist the state update"
  @spec update_path_state!(Post.t(), next_state :: Post.StateEnum.t()) :: Post.t()
  def update_path_state!(path, next_state) do
    path
    |> Post.changeset_state_transition(%{state: next_state})
    |> Repo.update!()
  end

  @doc "Machinery wrapper that converts errors to changest"
  @spec transition_state_to(Post.t(), Post.StateEnum.t()) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  def transition_state_to(path, next_state) do
    case Machinery.transition_to(path, Post.StateMachine, next_state) do
      {:ok, path} ->
        {:ok, path}

      {:error, cause} ->
        changeset = Post.changeset_state_transition_error(path, %{state: next_state}, cause)
        {:error, changeset}
    end
  end

  @spec update_path(Post.t(), attrs :: map()) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  @doc "when updating a new path, it transitions to draft state"
  def update_path(%Post{state: :new} = path, attrs) do
    with {:ok, path} = transition_state_to(path, :draft) do
      update_path(path, attrs)
    end
  end

  def update_path(%Post{state: state} = path, attrs) when state in @editable_state do
    path
    |> Post.changeset_update(attrs)
    |> Repo.update()
  end

  @spec publish_path(Post.t(), attrs :: map()) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  def publish_path(%Post{state: state} = path, attrs) when state in @publishable_state do
    with changeset = Post.changeset_publish(path, attrs),
         {:ok, path} <- Repo.update(changeset),
         {:ok, path} <- transition_state_to_published(path, :published) do
      {:ok, path}
    end
  end

  defp transition_state_to_published(%Post{state: :published} = path, :published), do: {:ok, path}
  defp transition_state_to_published(path, :published), do: transition_state_to(path, :published)

  @spec validate_publish_path(Post.t()) :: Ecto.Changeset.t(Post.t())
  def validate_publish_path(%Post{} = path, attrs \\ %{}) do
    path
    |> Post.changeset_publish(attrs)
    |> Map.put(:action, :insert)
  end

  @spec change_path(Post.t()) :: Ecto.Changeset.t(Post.t())
  def change_path(%Post{} = path, attrs \\ %{}) do
    Post.changeset_update(path, attrs)
  end
end
