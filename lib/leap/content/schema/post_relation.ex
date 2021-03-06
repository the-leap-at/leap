defmodule Leap.Content.Schema.PostRelation do
  @moduledoc "Join Schema holding relations between posts"

  use Leap, :schema

  alias Leap.Content.Schema.Post

  @type t() :: %__MODULE__{}

  schema "post_relations" do
    belongs_to :parent, Post
    belongs_to :child, Post

    timestamps()
  end
end
