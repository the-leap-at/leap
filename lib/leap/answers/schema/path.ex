defmodule Leap.Answers.Schema.Path do
  @moduledoc "Path schema"

  use Ecto.Schema
  import Ecto.Changeset

  alias Leap.Answers.Schema.Step

  @type t() :: %__MODULE__{}

  schema "paths" do
    field :title, :string
    field :description, :string

    has_many :steps, Step
    timestamps()
  end

  def changeset_update(path, attrs) do
    path
    |> cast(attrs, [:title, :description])
  end
end
