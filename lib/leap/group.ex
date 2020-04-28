defmodule Leap.Group do
  @moduledoc "The Grouping context"

  use Leap, :context

  alias Leap.Group.Categories

  ## CATEGORY ##
  defdelegate search_group(term), to: Categories, as: :search
end
