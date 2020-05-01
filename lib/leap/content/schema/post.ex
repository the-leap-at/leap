defmodule Leap.Content.Schema.Post do
  @moduledoc "Post schema"

  use Leap, :schema
  import EctoEnum

  alias __MODULE__
  alias Leap.Content.Posts
  alias Leap.Group.Schema.Category

  defenum StateEnum, ["new", "draft", "published"]
  defenum TypeEnum, ["question", "learn_path"]

  defmodule StateMachine do
    @moduledoc "State machine for post. See Machinary docs for guards or callbacks if needed"
    use Machinery,
      states: StateEnum.__valid_values__(),
      transitions: %{
        new: :draft,
        draft: :published
      }

    def guard_transition(post, "published") do
      # TODO here I can check the validity of the changeset before publishing
      # probably need to return a map of errors , to handle also the steps, or missing categories, etc
      post
    end

    def persist(post, next_state) do
      Posts.update_state!(post, next_state)
    end
  end

  @type t() :: %__MODULE__{}

  schema "posts" do
    field :title, :string
    field :body, :string
    field :type, TypeEnum
    field :state, StateEnum, default: "new"

    many_to_many(:children, Post,
      join_through: "post_relations",
      join_keys: [parent_id: :id, child_id: :id]
    )

    has_one :category, {"posts_categories", Category}

    many_to_many(:parents, Post,
      join_through: "post_relations",
      join_keys: [child_id: :id, parent_id: :id]
    )

    timestamps()
  end

  def changeset_update(post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> strip_html_tags(:body)
  end

  def changeset_publish(post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body, :type])
    |> strip_html_tags(:body)
  end

  def changeset_state_transition(post, attrs) do
    post
    |> cast(attrs, [:state])
    |> validate_required([:state])
  end

  def changeset_state_transition_error(post, attrs, error) do
    post
    |> cast(attrs, [:state])
    |> validate_required([:state])
    |> add_error(:state, error)
  end
end
