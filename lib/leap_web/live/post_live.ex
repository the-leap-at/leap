defmodule LeapWeb.PostLive do
  @moduledoc "Initiate update for posts"
  use LeapWeb, :live
  use TypedStruct

  alias Leap.Content
  alias Leap.Content.Schema.Post
  alias Leap.Group
  alias Leap.Group.Schema.Category

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [post: nil, post_component: nil, categories: []]}
  end

  def handle_params(%{"post_id" => post_id, "action" => "edit"}, _uri, socket) do
    post = get_post(post_id)
    categories = Group.all(Category)

    post_component =
      live_component(socket, LeapWeb.Components.EditPost,
        id: "edit_post_" <> to_string(post_id),
        post: post,
        categories: categories
      )

    {:noreply, assign(socket, post_component: post_component)}
  end

  def handle_params(%{"post_id" => post_id}, _uri, socket) do
    post = get_post(post_id)

    post_component =
      live_component(socket, LeapWeb.Components.ShowPost,
        id: "show_post_" <> to_string(post_id),
        post: post
      )

    {:noreply, assign(socket, post_component: post_component)}
  end

  defp get_post(post_id) do
    Post
    |> Content.get!(post_id)
    |> Content.with_preloads([:category])
  end
end
