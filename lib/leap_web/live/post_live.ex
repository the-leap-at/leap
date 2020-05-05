defmodule LeapWeb.PostLive do
  @moduledoc "Initiate update for posts"
  use LeapWeb, :live
  use TypedStruct

  alias LeapWeb.Live.Post.Mutations
  alias Leap.Content.Schema.Post

  defmodule State do
    @moduledoc false

    @typedoc "Post state"
    typedstruct do
      field :post, Post.t(), enforce: true
      field :post_changeset, Ecto.Changeset.t(Post.t())
      field :post_component, module(), enforce: true, default: LeapWeb.Components.ShowPost
    end
  end

  def mount(%{"post_id" => post_id}, _session, socket) do
    state = Mutations.init(%{post_id: post_id})
    {:ok, assign(socket, :state, state)}
  end

  def handle_params(%{"component" => "edit"}, _uri, %{assigns: %{state: state}} = socket) do
    state = Mutations.update(:post_component, LeapWeb.Components.EditPost, state)

    {:noreply, assign(socket, :state, state)}
  end

  def handle_params(_params, _uri, %{assigns: %{state: state}} = socket) do
    state = Mutations.update(:post_component, LeapWeb.Components.ShowPost, state)

    {:noreply, assign(socket, :state, state)}
  end

  def handle_info({:publish_post, post_params}, %{assigns: %{state: state}} = socket) do
    state = Mutations.publish_post(%{params: post_params}, state)

    {:noreply, assign(socket, :state, state)}
  end

  defp post_component(state, socket) do
    live_component(socket, state.post_component,
      id: "show_post_" <> to_string(state.post.id),
      state: state
    )
  end
end
