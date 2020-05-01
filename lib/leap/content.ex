defmodule Leap.Content do
  @moduledoc "The Content context"

  use Leap, :context

  alias Leap.Content.Posts

  ## PATH ##
  defdelegate update_post(post, attrs), to: Posts, as: :update
  defdelegate publish_post(post, attrs), to: Posts, as: :publish
  defdelegate validate_publish_post(post, attrs \\ %{}), to: Posts, as: :validate_publish
  defdelegate change_post(post, attrs \\ %{}), to: Posts, as: :change
end
