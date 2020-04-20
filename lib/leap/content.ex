defmodule Leap.Content do
  @moduledoc "The Answers context"

  use Leap, :context

  alias Leap.Content.Schema.Post
  alias Leap.Content.Posts

  @type schema() :: Post.t()

  ## PATH ##
  defdelegate update_post(post, attrs), to: Posts
  defdelegate publish_post(post, attrs), to: Posts
  defdelegate validate_publish_post(post, attrs \\ %{}), to: Posts
  defdelegate change_post(post, attrs \\ %{}), to: Posts
end
