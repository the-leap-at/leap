defmodule Leap.Content do
  @moduledoc "The Content context"

  use Leap, :context

  alias Leap.Content.Posts

  # AUTHORIZATION

  defdelegate authorize(action, user, params), to: Leap.Content.Policy

  # POST

  ## USER SCOPED

  defdelegate update_post(user, post, attrs), to: Posts, as: :update
  defdelegate publish_post(user, post, attrs), to: Posts, as: :publish
  defdelegate home_posts(user), to: Posts, as: :home

  ## UNSCOPED

  defdelegate create_post!(attrs), to: Posts, as: :create!
  defdelegate add_post_parent!(post, parent), to: Posts, as: :add_parent!
  defdelegate add_post_child!(post, child), to: Posts, as: :add_child!
  defdelegate validate_publish_post(post, attrs \\ %{}), to: Posts, as: :validate_publish
  defdelegate change_post(post, attrs \\ %{}), to: Posts, as: :change
end
