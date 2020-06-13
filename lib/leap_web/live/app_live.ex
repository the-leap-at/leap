defmodule LeapWeb.AppLive do
  @moduledoc """
  - plays the role of layout for the SPA
  - plays the role of router
  """
  use LeapWeb, :live

  alias Leap.Accounts
  alias Leap.Accounts.Schema.User

  @onboarding_state [:authenticated, :display_name_set]

  def mount(_params, %{"current_user_id" => current_user_id}, socket) do
    socket = assign_new(socket, :current_user, fn -> Accounts.get!(User, current_user_id) end)

    navbar_component =
      live_component(socket, LeapWeb.Components.Container.Navbar,
        id: "navbar",
        current_user: socket.assigns.current_user
      )

    socket = assign(socket, :navbar_component, navbar_component)

    {:ok, socket}
  end

  def handle_params(
        _params,
        _uri,
        %{assigns: %{current_user: %User{state: state} = current_user}} = socket
      )
      when state in @onboarding_state do
    content_component =
      live_component(socket, LeapWeb.Components.Container.Onboarding,
        id: "onboarding",
        current_user: current_user
      )

    {:noreply, assign(socket, :content_component, content_component)}
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

  def handle_params(
        _params,
        _uri,
        %{assigns: %{current_user: %User{state: :onboarded} = current_user}} = socket
      ) do
    content_component =
      live_component(socket, LeapWeb.Components.Container.Home,
        id: "home",
        current_user: current_user
      )

    {:noreply, assign(socket, :content_component, content_component)}
  end
end
