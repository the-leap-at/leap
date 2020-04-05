defmodule Leap.Answers do
  @moduledoc "The Answers context"

  alias Leap.Repo
  alias Leap.Answers.Schema.Path

  @type schema() :: Path.t()

  @spec get(Ecto.Queryable.t(), id :: integer()) :: schema() | nil
  def get(queryable, id), do: Repo.get(queryable, id)

  @spec get!(Ecto.Queryable.t(), id :: integer()) :: schema() | nil
  def get!(queryable, id), do: Repo.get(queryable, id)

  ## PATH ##

  @spec update_path(Path.t(), attrs :: map()) ::
          {:ok, Path.t()} | {:error, Ecto.Changeset.t(Path.t())}
  @doc "when updating a new path, it transitions to draft state"
  def update_path(%Path{state: :new} = path, attrs) do
    with {:ok, path} = Machinery.transition_to(path, Path.StateMachine, :draft) do
      update_path(path, attrs)
    end
  end

  def update_path(%Path{state: :draft} = path, attrs) do
    path
    |> Path.changeset_update(attrs)
    |> Repo.update()
  end

  @spec change_path(Path.t()) :: Ecto.Changeset.t(Path.t())
  def change_path(%Path{} = path, attrs \\ %{}) do
    Path.changeset_update(path, attrs)
  end
end
