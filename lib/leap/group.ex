defmodule Leap.Group do
  @moduledoc "The Grouping context"

  use Leap, :context

  alias Leap.Group.Categories

  ## CATEGORY ##
  defdelegate search_category(term), to: Categories, as: :search
  defdelegate add_user_fav_category!(params), to: Categories, as: :add_user_fav!
  defdelegate remove_user_fav_category!(params), to: Categories, as: :remove_user_fav!
end
