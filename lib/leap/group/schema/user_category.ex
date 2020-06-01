defmodule Leap.Group.Schema.UserCategory do
  @moduledoc "Join Schema between users and categories. Used to hold the user favourite categor"

  use Leap, :schema

  alias Leap.Accounts.Schema.User
  alias Leap.Group.Schema.Category

  @type t() :: %__MODULE__{}

  schema "users_categories" do
    belongs_to :user, User
    belongs_to :category, Category

    timestamps()
  end
end
