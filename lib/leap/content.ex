defmodule Leap.Content do
  @moduledoc "The Content context"

  use Leap, :context

  alias Leap.Content.Posts

  ## POST ##
  defdelegate create_post!(attrs), to: Posts, as: :create!
  defdelegate update_post(post, attrs), to: Posts, as: :update
  defdelegate update_post!(post, attrs), to: Posts, as: :update!
  defdelegate publish_post(post, attrs), to: Posts, as: :publish
  defdelegate validate_publish_post(post, attrs \\ %{}), to: Posts, as: :validate_publish
  defdelegate add_post_parent!(post, parent), to: Posts, as: :add_parent!
  defdelegate add_post_child!(post, child), to: Posts, as: :add_child!
  defdelegate change_post(post, attrs \\ %{}), to: Posts, as: :change
end
