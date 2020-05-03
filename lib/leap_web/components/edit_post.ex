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
      field :action, list() | keyword(), default: [:init]
      field :debounce, integer(), default: @debounce
      field :post, Post.t(), enforce: true
      field :form, Phoenix.HTML.Form.t(), enforce: true
    end
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: [:init], id: component_id, post: post}, socket) do
    state = %State{
      component_id: component_id,
      post: post,
      form: post_form(component_id, post)
    }

    {:ok, assign(socket, %{state: state})}
  end

  # This is called also from other sub-components
  def update(
        %{action: [post: :update], payload: post_params},
        %{assigns: %{state: state}} = socket
      ) do
    case Content.update_post(state.post, post_params) do
      {:ok, post} ->
        post = Content.with_preloads(post, [:category], force: true)

        state = %State{
          state
          | action: [post: [update: :ok]],
            post: post,
            form: post_form(state.component_id, post)
        }

        {:ok, assign(socket, :state, state)}

      {:error, changeset} ->
        state = %State{
          state
          | action: [post: [update: :error]],
            form: post_form(state.component_id, changeset)
        }

        {:ok, assign(socket, :state, state)}
    end
  end

  @doc "Live updates a draft post"
  def handle_event(
        "update_post",
        %{"post" => post_params},
        %{assigns: %{state: %{post: %Post{state: post_state}} = state}} = socket
      )
      when post_state in [:new, :draft] do
    send(
      self(),
      {:perform_action, {__MODULE__, state.component_id, [post: :update], post_params}}
    )

    {:noreply, socket}
  end

  def handle_event(
        "update_post",
        %{"post" => post_params},
        %{assigns: %{state: %{post: %Post{state: :published}} = state}} = socket
      ) do
    changeset = Content.validate_publish_post(state.post, post_params)

    state = %State{
      state
      | action: [post: :validate],
        form: post_form(state.component_id, changeset)
    }

    {:noreply, assign(socket, :state, state)}
  end

  @doc "Publish a draft post or already published post (edit)"
  def handle_event("publish_post", %{"post" => post_params}, %{assigns: %{state: state}} = socket) do
    case Content.publish_post(state.post, post_params) do
      {:ok, post} ->
        state = %State{
          state
          | action: [post: [publish: :ok]],
            post: post,
            form: post_form(state.component_id, post)
        }

        socket = assign(socket, :state, state)
        {:noreply, push_patch(socket, to: Routes.live_path(socket, LeapWeb.PostLive, post.id))}

      {:error, changeset} ->
        state = %State{
          state
          | action: [post: [publish: :ok]],
            form: post_form(state.component_id, changeset)
        }

        {:noreply, assign(socket, :state, state)}
    end
  end

  # The form needs to be used for categories. And categories are outside the form.
  # Instead of keeping the changeset in the state, we keep the form
  defp post_form(component_id, %Ecto.Changeset{} = changeset) do
    form_for(changeset, "#",
      phx_change: "update_post",
      phx_submit: "publish_post",
      phx_target: "#" <> component_id
    )
  end

  defp post_form(component_id, %Post{} = post) do
    post_form(component_id, Content.change_post(post))
  end

  defp markdown_textarea_component(form, state, socket) do
    live_component(socket, LeapWeb.Components.MarkdownTextarea,
      id: "#{state.component_id}_body",
      action: state.action,
      form: form,
      field: :body,
      value: state.post.body
    )
  end

  defp edit_category_component(form, state, socket) do
    live_component(socket, LeapWeb.Components.EditPost.EditCategory,
      id: "#{state.component_id}_category",
      action: state.action,
      edit_post_component_id: state.component_id,
      form: form,
      category: state.post.category
    )
  end
end
