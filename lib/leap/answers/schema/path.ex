defmodule Leap.Answers.Schema.Path do
  @moduledoc "Path schema"

  use Leap, :schema
  import EctoEnum

  alias Leap.Answers.Paths
  alias Leap.Answers.Schema.Step

  defenum StateEnum, ["new", "draft", "published"]

  defmodule StateMachine do
    @moduledoc "State machine for path. See Machinary docs for guards or callbacks if needed"
    use Machinery,
      states: StateEnum.__valid_values__(),
      transitions: %{
        new: :draft,
        draft: :published,
        published: :draft
      }

    def guard_transition(path, "published") do
      # TODO here I can check the validity of the changeset before publishing
      # probably need to return a map of errors , to handle also the steps, or missing categories, etc
      path
    end

    def persist(path, next_state) do
      Paths.update_path_state!(path, next_state)
    end
  end

  @type t() :: %__MODULE__{}

  schema "paths" do
    field :title, :string
    field :description, :string
    field :state, StateEnum, default: "new"

    has_many :steps, Step
    timestamps()
  end

  def changeset_update(path, attrs) do
    path
    |> cast(attrs, [:title, :description])
    |> strip_html_tags(:description)
  end

  def changeset_update_state(path, attrs) do
    path
    |> cast(attrs, [:state])
    |> validate_required([:state])
  end
end
