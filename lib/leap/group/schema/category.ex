defmodule Leap.Group.Schema.Category do
  @moduledoc "Category schema"

  use Leap, :schema

  alias Leap.Content.Schema.Post

  @type t() :: %__MODULE__{}

  schema "categories" do
    field :name, :string
    has_many :posts, Post

    timestamps()
  end
end
