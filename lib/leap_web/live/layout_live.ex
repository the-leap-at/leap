defmodule LeapWeb.LayoutLive do
  @moduledoc """
  - plays the role of layout for the SPA
  - plays the role of router
  """
  use LeapWeb, :live

  def mount(_params, _session, socket) do
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
end
