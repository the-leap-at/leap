defmodule Leap.Content do
  @moduledoc "The Content context"

  use Leap, :context

  alias Leap.Content.Posts

  ## PATH ##
  defdelegate update_post(post, attrs), to: Posts
  defdelegate publish_post(post, attrs), to: Posts
  defdelegate validate_publish_post(post, attrs \\ %{}), to: Posts
  defdelegate change_post(post, attrs \\ %{}), to: Posts
end
