defmodule Leap.Answers.Paths do
  @moduledoc """
  Functions specific to Paths.
  The functions that are not exposed throught Answers (defdelegate) are only context internal

  """
  alias Leap.Repo
  alias Leap.Answers.Schema.Path

  @editable_state [:draft, :published]
  @publishable_state [:draft, :published]

  @doc "Function used by Machinery to persist the state update"
  @spec update_path_state!(Path.t(), next_state :: Path.StateEnum.t()) :: Path.t()
  def update_path_state!(path, next_state) do
    path
    |> Path.changeset_state_transition(%{state: next_state})
    |> Repo.update!()
  end

  @doc "Machinery wrapper that converts errors to changest"
  @spec transition_state_to(Path.t(), Path.StateEnum.t()) ::
          {:ok, Path.t()} | {:error, Ecto.Changeset.t(Path.t())}
  def transition_state_to(path, next_state) do
    case Machinery.transition_to(path, Path.StateMachine, next_state) do
      {:ok, path} ->
        {:ok, path}

      {:error, cause} ->
        changeset = Path.changeset_state_transition_error(path, %{state: next_state}, cause)
        {:error, changeset}
    end
  end

  @spec update_path(Path.t(), attrs :: map()) ::
          {:ok, Path.t()} | {:error, Ecto.Changeset.t(Path.t())}
  @doc "when updating a new path, it transitions to draft state"
  def update_path(%Path{state: :new} = path, attrs) do
    with {:ok, path} = transition_state_to(path, :draft) do
      update_path(path, attrs)
    end
  end

  def update_path(%Path{state: state} = path, attrs) when state in @editable_state do
    path
    |> Path.changeset_update(attrs)
    |> Repo.update()
  end

  @spec publish_path(Path.t(), attrs :: map()) ::
          {:ok, Path.t()} | {:error, Ecto.Changeset.t(Path.t())}
  def publish_path(%Path{state: state} = path, attrs) when state in @publishable_state do
    with changeset = Path.changeset_publish(path, attrs),
         {:ok, path} <- Repo.update(changeset),
         {:ok, path} <- transition_state_to_published(path, :published) do
      {:ok, path}
    end
  end

  defp transition_state_to_published(%Path{state: :published} = path, :published), do: {:ok, path}
  defp transition_state_to_published(path, :published), do: transition_state_to(path, :published)

  @spec validate_publish_path(Path.t()) :: Ecto.Changeset.t(Path.t())
  def validate_publish_path(%Path{} = path, attrs \\ %{}) do
    path
    |> Path.changeset_publish(attrs)
    |> Map.put(:action, :insert)
  end

  @spec change_path(Path.t()) :: Ecto.Changeset.t(Path.t())
  def change_path(%Path{} = path, attrs \\ %{}) do
    Path.changeset_update(path, attrs)
  end
end
