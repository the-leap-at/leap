defmodule LeapWeb.Components.ShowPost do
  @moduledoc """
  - Shows posts
  """
  use LeapWeb, :component
  use TypedStruct

  alias Leap.Content.Schema.Post

  defmodule State do
    @moduledoc false

    @typedoc "ShowPost Component state"
    typedstruct do
      field :component_id, String.t(), enforce: true
      field :post, Post.t(), enforce: true
    end
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(
        %{action: :refresh_post, params: %{post: post}},
        %{assigns: %{state: state}} = socket
      ) do
    state = %State{state | post: post}

    {:ok, assign(socket, :state, state)}
  end

  def update(%{id: component_id, post: post}, socket) do
    state = %State{
      component_id: component_id,
      post: post
    }

    {:ok, assign(socket, :state, state)}
  end

  defp updates_component(state, socket) do
    live_component(socket, LeapWeb.Components.ShowPost.Updates,
      id: "#{state.component_id}_update",
      show_post_component_id: state.component_id,
      post: state.post
    )
  end
end