defmodule Leap.Group.Categories do
  @moduledoc """
  Functions specific to Categories.
  The functions that are not exposed throught Content (defdelegate) are only context internal
  """
  alias Leap.Repo
  alias Leap.Group.Queries

  alias Leap.Group
  alias Leap.Group.Schema.Category
  alias Leap.Group.Schema.UserCategory

  @spec search(term :: binary()) :: [Category.t()]
  def search(term) do
    term
    |> format_search_term()
    |> Queries.search_category()
    |> Repo.all()
  end

  # allow search by partial words
  defp format_search_term(term) do
    term =
      term
      |> String.split(~r/\W/u, trim: true)
      |> Enum.join(":* & ")

    term <> ":*"
  end

  @spec add_user_fav!(params :: map()) :: UserCategory.t()
  def add_user_fav!(%{user_id: user_id, category_id: category_id}) do
    Repo.insert!(%UserCategory{user_id: user_id, category_id: category_id})
  end

  @spec remove_user_fav!(params :: map()) :: UserCategory.t()
  def remove_user_fav!(%{user_id: _, category_id: _} = params) do
    UserCategory
    |> Group.get_by!(params)
    |> Repo.delete!()
  end
end
