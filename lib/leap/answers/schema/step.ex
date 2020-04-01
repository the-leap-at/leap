defmodule Leap.Answers.Schema.Step do
  @moduledoc "Step schema"

  use Ecto.Schema

  alias Leap.Answers.Schema.Path

  @type t() :: %__MODULE__{}

  schema "steps" do
    field :title, :string
    field :position, :integer
    field :description, :string
    field :url, :string
    field :pricing, :string

    belongs_to :path, Path

    timestamps()
  end
end
