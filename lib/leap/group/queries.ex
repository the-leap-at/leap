defmodule Leap.Group.Queries do
  @moduledoc "Group query builder"

  import Ecto.Query, warn: false

  alias Leap.Group.Schema.Category

  ### BASIC - Starts from a Schema
  def search_category(term) do
    from category in Category,
      as: :category,
      where:
        fragment(
          "to_tsvector('english', coalesce(?, ' ')) @@ to_tsquery(?)",
          category.name,
          ^term
        )
  end

  ### ADVANCED - Makes use of basic queries

  ### FILTER - Additional filtering. Takes a query as first argument
end
