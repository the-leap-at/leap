defmodule Leap.Answers do
  @moduledoc "The Answers context"

  use Leap, :context

  alias Leap.Answers.Schema.Path
  alias Leap.Answers.Paths

  @type schema() :: Path.t()

  ## PATH ##
  defdelegate update_path(path, attrs), to: Paths
  defdelegate publish_path(path, attrs), to: Paths
  defdelegate validate_publish_path(path, attrs \\ %{}), to: Paths
  defdelegate change_path(path, attrs \\ %{}), to: Paths
end
