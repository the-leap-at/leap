defmodule LeapWeb.PostLive do
  @moduledoc "Initiate update for posts"
  use LeapWeb, :live
  use TypedStruct

  alias Leap.Content
  alias Leap.Content.Schema.Post

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [post: nil, post_component: nil]}
  end

  def handle_params(%{"post_id" => post_id, "action" => "edit"}, _uri, socket) do
    post = Content.get!(Post, post_id)

    post_component =
      live_component(socket, LeapWeb.Components.EditPost,
        id: "edit_post_" <> to_string(post_id),
        post: post
      )

    {:noreply, assign(socket, post_component: post_component)}
  end

  def handle_params(%{"post_id" => post_id}, _uri, socket) do
    post = Content.get!(Post, post_id)

    post_component =
      live_component(socket, LeapWeb.Components.ShowPost,
        id: "show_post_" <> to_string(post_id),
        post: post
      )

    {:noreply, assign(socket, post_component: post_component)}
  end
end
