defmodule LeapWeb.Components.Container.Home do
  use LeapWeb, :component

  alias Leap.Content
  alias Leap.Content.Schema.Post

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :init} = assigns, socket) do
    posts = Content.home_posts(assigns.current_user)
    assigns = Map.merge(assigns, %{posts: posts})
    {:ok, assign(socket, assigns)}
  end

  def post_details_component(%Post{id: post_id} = post, socket) do
    live_component(socket, LeapWeb.Components.Shared.PostDetails,
      action: :init,
      id: "post_preview#{to_string(post_id)}",
      post: post
    )
  end
end
