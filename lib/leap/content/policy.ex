defmodule Leap.Content.Policy do
  @moduledoc "Policies for content"
  @behaviour Bodyguard.Policy

  alias Leap.Accounts.Schema.User
  alias Leap.Content.Schema.Post

  def authorize(_action, %User{id: user_id, state: :onboarded}, %Post{user_id: user_id}), do: :ok

  def authorize(_action, _user, _params), do: :error
end
