defmodule Leap.Accounts do
  @moduledoc "The Accounts context"

  use Leap, :context

  alias Leap.Accounts.Users

  defdelegate update_user(user, attrs), to: Users, as: :update
  defdelegate transition_user_state_to(user, next_state), to: Users, as: :transition_state_to
  defdelegate change_user(user, attrs \\ %{}), to: Users, as: :change
end
