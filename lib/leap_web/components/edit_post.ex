defmodule LeapWeb.Components.EditPost do
  @moduledoc """
  - Edit posts
  """
  use LeapWeb, :component
  use TypedStruct

  alias Leap.Content
  alias Leap.Content.Schema.Post

  defmodule State do
    @moduledoc false
    @debounce 1000

    @typedoc "EditPost Component state"
    typedstruct do
      field :component_id, String.t(), enforce: true
      field :debounce, integer(), default: @debounce
      field :post, Post.t(), enforce: true
      field :post_changeset, Ecto.Changeset.t(Post.t())
    end
  end

  def mount(socket) do
    {:ok, socket}
  end

  # TODO: move the update in the handle event. We do not need to go throught the liveview
  def update(%{action: :update_post, params: post_params}, %{assigns: %{state: state}} = socket) do
    case Content.update_post(state.post, post_params) do
      {:ok, post} ->
        state = %State{state | post: post, post_changeset: Content.change_post(post)}

        {:ok, assign(socket, :state, state)}

      {:error, changeset} ->
        state = %State{state | post_changeset: changeset}

        {:ok, assign(socket, :state, state)}
    end
  end

  def update(%{id: component_id, post: post}, socket) do
    state = %State{
      component_id: component_id,
      post: post,
      post_changeset: Content.change_post(post)
    }

    {:ok, assign(socket, :state, state)}
  end

  @doc "Live updates a draft post"
  def handle_event("update_post", %{"post" => post_params}, %{assigns: %{state: state}} = socket) do
    case state.post do
      %Post{state: post_state} when post_state in [:new, :draft] ->
        send(
          self(),
          {:perform_action, {__MODULE__, state.component_id, :update_post, post_params}}
        )

        {:noreply, socket}

      %Post{state: :published} ->
        post = Content.validate_publish_post(state.post, post_params)
        state = %State{state | post_changeset: post}

        {:noreply, assign(socket, :state, state)}
    end
  end

  @doc "Publish a draft post or already published post (edit)"
  def handle_event("publish_post", %{"post" => post_params}, %{assigns: %{state: state}} = socket) do
    case Content.publish_post(state.post, post_params) do
      {:ok, post} ->
        state = %State{state | post: post, post_changeset: Content.change_post(post)}
        socket = assign(socket, :state, state)
        {:noreply, push_patch(socket, to: Routes.live_path(socket, LeapWeb.PostLive, post.id))}

      {:error, changeset} ->
        state = %State{state | post_changeset: changeset}
        {:noreply, assign(socket, :state, state)}
    end
  end

  defp markdown_textarea_component(form, state, socket) do
    live_component(socket, LeapWeb.Components.MarkdownTextarea,
      id: "#{state.component_id}_body",
      debounce: state.debounce,
      form: form,
      field: :body,
      value: state.post.body
    )
  end
end
