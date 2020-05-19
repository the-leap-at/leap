defmodule LeapWeb.AppLive do
  @moduledoc """
  - plays the role of layout for the SPA
  - plays the role of router
  """
  use LeapWeb, :live

  def mount(_params, %{"current_user_id" => current_user_id}, socket) do
    IO.inspect(current_user_id)
    navbar_component = live_component(socket, LeapWeb.Components.Container.Navbar, id: "navbar")
    {:ok, assign(socket, :navbar_component, navbar_component)}
  end

  def handle_params(%{"container" => "learn_path", "post_id" => post_id}, _uri, socket) do
    content_component =
      live_component(socket, LeapWeb.Components.Container.LearnPath,
        id: "learn_path_#{to_string(post_id)}",
        post_id: post_id
      )

    {:noreply, assign(socket, :content_component, content_component)}
  end

  def handle_params(%{"container" => "question", "post_id" => post_id}, _uri, socket) do
    content_component =
      live_component(socket, LeapWeb.Components.Container.Question,
        id: "question_#{to_string(post_id)}",
        post_id: post_id
      )

    {:noreply, assign(socket, :content_component, content_component)}
  end

  def handle_params(_params, _uri, %{assigns: %{live_action: :home}} = socket) do
    {:noreply, assign(socket, :content_component, nil)}
  end
end
