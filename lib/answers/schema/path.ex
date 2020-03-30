defmodule Leap.Answers.Schema.Path do
  @moduledoc "Path schema"

  use Ecto.Schema

  alias Leap.Answers.Schema.Step

  @type t() :: %__MODULE__{}

  schema "paths" do
    field :title, :string
    field :description, :string

    has_many :steps, Step
    timestamps()
  end
end
