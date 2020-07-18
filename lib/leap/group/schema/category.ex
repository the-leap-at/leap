defmodule Leap.Group.Schema.Category do
  @moduledoc "Category schema"

  use Leap, :schema

  alias Leap.Group.Schema.UserCategory
  alias Leap.Content.Schema.Post
  alias Leap.Accounts.Schema.User

  @type t() :: %__MODULE__{}

  schema "categories" do
    field :name, :string
    has_many :posts, Post
    many_to_many :users, User, join_through: UserCategory

    timestamps()
  end
end
