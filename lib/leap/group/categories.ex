defmodule Leap.Group.Categories do
  @moduledoc """
  Functions specific to Categories.
  The functions that are not exposed throught Content (defdelegate) are only context internal
  """
  alias Leap.Repo
  import Ecto.Query, warn: false
  alias Leap.Group.Schema.Category

  @spec search(term :: binary()) :: [Category.t()]
  def search(term) do
    term = format_search_term(term)

    where(
      Category,
      fragment(
        "to_tsvector('english', coalesce(name, ' ')) @@ to_tsquery(?)",
        ^term
      )
    )
    |> Repo.all()
  end

  # allow search by partial word
  defp format_search_term(term) do
    term =
      term
      |> String.split(~r/\W/u, trim: true)
      |> Enum.join(":* & ")

    term <> ":*"
  end
end
