defmodule LeapWeb.Components.Container.LearnPath do
  use LeapWeb, :component

  alias Leap.Content
  alias Leap.Content.Schema.Post

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :init} = assigns, socket) do
    post = get_post(assigns.post_id)

    post_component =
      live_component(socket, LeapWeb.Components.Main.Post,
        action: :init,
        id: "post_#{to_string(assigns.post_id)}",
        current_user: assigns.current_user,
        post: post
      )

    assigns = Map.merge(assigns, %{post_component: post_component})
    {:ok, assign(socket, assigns)}
  end

  defp get_post(post_id) do
    Post
    |> Content.get!(post_id)
    |> Content.with_preloads([:category, :parents])
  end
end
