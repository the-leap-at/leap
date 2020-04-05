defmodule Leap.Answers.Paths do
  @moduledoc """
  Functions specific to Paths.
  The functions that are not exposed throught Answers (defdelegate) are only context internal

  """
  alias Leap.Repo
  alias Leap.Answers.Schema.Path

  @doc "Context internal function to update the path state"
  @spec update_path_state!(Path.t(), next_state :: Path.StateEnum.t()) ::
          {:ok, Path.t()} | {:error, Ecto.Changeset.t(Path.t())}
  def update_path_state!(path, next_state) do
    path
    |> Path.changeset_update_state(%{state: next_state})
    |> Repo.update!()
  end
end
