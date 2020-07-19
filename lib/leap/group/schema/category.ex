defmodule Leap.Group.Schema.Category do
  @moduledoc "Category schema"

  use Leap, :schema
  import EctoEnum

  alias Leap.Group.Schema.UserCategory
  alias Leap.Content.Schema.Post
  alias Leap.Accounts.Schema.User

  @category_name [
    "technology",
    "science",
    "design",
    "education",
    "psychology",
    "literature",
    "media",
    "art",
    "crafts",
    "architecture",
    "food",
    "health",
    "sports",
    "travel",
    "business",
    "services",
    "finance",
    "legal",
    "management",
    "marketing",
    "sales",
    "politics",
    "other"
  ]

  defenum NameEnum, @category_name

  @type t() :: %__MODULE__{}

  schema "categories" do
    field :name, :string
    has_many :posts, Post
    many_to_many :users, User, join_through: UserCategory

    timestamps()
  end

  def category_name do
    @category_name
  end
end
