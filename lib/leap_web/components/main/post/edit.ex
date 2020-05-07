defmodule LeapWeb.Components.Main.Post.Edit do
  @moduledoc """
  - Edit posts
  """
  use LeapWeb, :component

  alias Leap.Content
  alias Leap.Content.Schema.Post

  @delay 1000

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    post_form = post_form(assigns.id, assigns.state.post_changeset)
    assigns = Map.merge(assigns, %{post_form: post_form})

    {:ok, assign(socket, assigns)}
  end

  @doc "Live updates a draft post"
  def handle_event(
        "update_post",
        %{"post" => post_params},
        %{assigns: %{state: %{post: %Post{state: post_state}} = state}} = socket
      )
      when post_state in [:new, :draft] do
    delay_send_to_main(@delay, :update_post, post_params, state)

    {:noreply, socket}
  end

  def handle_event(
        "update_post",
        %{"post" => post_params},
        %{assigns: %{state: %{post: %Post{state: :published}} = state}} = socket
      ) do
    delay_send_to_main(@delay, :validate_publish_post, post_params, state)

    {:noreply, socket}
  end

  @doc "Publish a draft post or already published post (edit)"
  def handle_event("publish_post", %{"post" => post_params}, %{assigns: %{state: state}} = socket) do
    send_to_main(:publish_post, post_params, state)
    send_to_main(:show_post, %{}, state)

    {:noreply, socket}
  end

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

  defp markdown_textarea_component(id, post_form, state, socket) do
    live_component(socket, LeapWeb.Components.Shared.MarkdownTextarea,
      id: "#{id}_body",
      post_form: post_form,
      field: :body,
      value: Content.get_field(state.post_changeset, :body)
    )
  end

  defp edit_category_component(id, post_form, state, socket) do
    live_component(socket, LeapWeb.Components.Main.Post.Edit.EditCategory,
      id: "#{id}_category",
      post_form: post_form,
      state: state
    )
  end
end
