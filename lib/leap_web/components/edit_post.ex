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
    {:ok, socket, temporary_assigns: [categories: []]}
  end

  def update(%{id: component_id, post: post, categories: categories}, socket) do
    state = %State{
      component_id: component_id,
      post: post,
      post_changeset: Content.change_post(post)
    }

    {:ok, assign(socket, %{state: state, categories: categories})}
  end

  @doc "Live updates a draft post"
  def handle_event(
        "update_post",
        %{"post" => post_params},
        %{assigns: %{state: %{post: %Post{state: post_state}} = state}} = socket
      )
      when post_state in [:new, :draft] do
    case Content.update_post(state.post, post_params) do
      {:ok, post} ->
        state = %State{state | post: post, post_changeset: Content.change_post(post)}

        {:noreply, assign(socket, :state, state)}

      {:error, changeset} ->
        state = %State{state | post_changeset: changeset}

        {:noreply, assign(socket, :state, state)}
    end
  end

  def handle_event(
        "update_post",
        %{"post" => post_params},
        %{assigns: %{state: %{post: %Post{state: :publised}} = state}} = socket
      ) do
    post = Content.validate_publish_post(state.post, post_params)
    state = %State{state | post_changeset: post}

    {:noreply, assign(socket, :state, state)}
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

  defp edit_category_component(categories, state, socket) do
    live_component(socket, LeapWeb.Components.EditPost.EditCategory,
      id: "#{state.component_id}_category",
      post: state.post,
      categories: categories
    )
  end
end
