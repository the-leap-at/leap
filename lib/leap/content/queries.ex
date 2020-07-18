defmodule Leap.Content.Queries do
  @moduledoc "Content query builder"

  import Ecto.Query, warn: false

  alias Leap.Content.Schema.Post

  ### BASIC - Starts from a Schema

  def published_posts_query() do
    from(post in Post,
      as: :post,
      where: post.state == "published",
      order_by: [desc: post.inserted_at]
    )
  end

  ### ADVANCED - Makes use of basic queries

  def posts_for_user_favorites(user_id) do
    from([post: post] in published_posts_query(),
      join: category in assoc(post, :category),
      as: :category,
      join: user in assoc(category, :users),
      as: :user,
      where: user.id == ^user_id
    )
  end

  ### FILTER - Additional filtering. Takes a query as first argument

  def do_limit(query, limit) do
    from q in query, limit: ^limit
  end

  def do_preload(query, preloads) do
    from q in query, preload: ^preloads
  end
end
