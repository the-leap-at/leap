defmodule LeapWeb.Components.Container.Home do
  use LeapWeb, :component

  alias LeapWeb.AppLive
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

  defp post_link(%Post{type: post_type, title: title, id: post_id}, socket) do
    live_patch(title,
      to: Routes.live_path(socket, AppLive, post_type, post_id),
      class: "is-size-5"
    )
  end

  defp post_icon(%Post{type: :question}), do: "fa-question"
  defp post_icon(%Post{type: :learn_path}), do: "fa-tasks"
end
