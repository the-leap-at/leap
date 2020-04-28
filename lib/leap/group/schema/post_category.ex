defmodule Leap.Group.Schema.PostCategory do
  @moduledoc "Join schema"
  use Leap, :schema

  alias Leap.Group.Schema.Category
  alias Leap.Content.Schema.Post

  @type t() :: %__MODULE__{}

  schema "posts_categories" do
    belongs_to :post, Post
    belongs_to :category, Category

    timestamps()
  end
end
