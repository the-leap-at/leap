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
      field :categories, [Category.t()], default: []
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

  def handle_info({:update_post, post_params}, %{assigns: %{state: state}} = socket) do
    state = Mutations.update_post(%{params: post_params}, state)

    {:noreply, assign(socket, :state, state)}
  end

  def handle_info({:validate_publish_post, post_params}, %{assigns: %{state: state}} = socket) do
    state = Mutations.validate_publish_post(%{params: post_params}, state)

    {:noreply, assign(socket, :state, state)}
  end

  def handle_info({:publish_post, post_params}, %{assigns: %{state: state}} = socket) do
    state = Mutations.publish_post(%{params: post_params}, state)

    {:noreply, assign(socket, :state, state)}
  end

  def handle_info({:search_category, search_term}, %{assigns: %{state: state}} = socket) do
    state = Mutations.search_category(%{term: search_term}, state)

    {:noreply, assign(socket, :state, state)}
  end

  def handle_info(:redirect_to_show_post, %{assigns: %{state: state}} = socket) do
    if state.post_changeset.valid? do
      {:noreply,
       push_patch(socket, to: Routes.live_path(socket, LeapWeb.PostLive, state.post.id))}
    else
      {:noreply, socket}
    end
  end

  defp post_component(%{post_component: LeapWeb.Components.ShowPost} = state, socket) do
    live_component(socket, state.post_component,
      id: "show_post_" <> to_string(state.post.id),
      state: state
    )
  end

  defp post_component(%{post_component: LeapWeb.Components.EditPost} = state, socket) do
    live_component(socket, state.post_component,
      id: "edit_post_" <> to_string(state.post.id),
      state: state
    )
  end
end
