defmodule LeapWeb.Components.Shared.PostDetails do
  @moduledoc """
  Post details to be used for eg in a list of posts.
  Needs a Post with required preloads to be passed in
  """

  use LeapWeb, :component

  alias LeapWeb.AppLive
  alias Leap.Content.Schema.Post

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :init} = assigns, socket) do
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
