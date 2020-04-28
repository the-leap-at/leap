defmodule Leap.Group.Schema.Category do
  @moduledoc "Category schema"
  use Leap, :schema

  alias Leap.Content.Schema.Post

  @type t() :: %__MODULE__{}

  schema "categories" do
    field :name, :string
    many_to_many :posts, Post, join_through: "posts_categories"

    timestamps()
  end
end
