defmodule LeapWeb.Components.ShowPost.Updates do
  @moduledoc """
  Add updates to posts
  """
  use LeapWeb, :component
  use TypedStruct

  alias LeapWeb.Components.ShowPost
  alias Leap.Content
  alias Leap.Content.Schema.Post

  defmodule State do
    @moduledoc false
    @debounce 1000

    @typedoc "Update Component state"
    typedstruct do
      field :component_id, String.t(), enforce: true
      field :show_post_component_id, String.t(), enforce: true
      field :debounce, integer(), default: @debounce
      field :post, Post.t(), enforce: true
      field :post_changeset, Ecto.Changeset.t(Post.t())
      field :body, String.t() | nil, default: nil
      field :edit, boolean(), default: false
    end
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    state = %State{
      component_id: assigns.id,
      show_post_component_id: assigns.show_post_component_id,
      post: assigns.post,
      post_changeset: Content.change_post(assigns.post)
    }

    {:ok, assign(socket, :state, state)}
  end

  def handle_event(
        "publish_update",
        %{"post" => %{"body" => update_body}},
        %{assigns: %{state: state}} = socket
      ) do
    post_params = %{"body" => patch_post_body(update_body, state.post.body)}

    case Content.publish_post(state.post, post_params) do
      {:ok, post} ->
        state = %State{
          state
          | post: post,
            post_changeset: Content.change_post(post),
            body: nil,
            edit: false
        }

        send(
          self(),
          {:perform_action,
           {ShowPost, state.show_post_component_id, :refresh_post, %{post: post}}}
        )

        {:noreply, assign(socket, :state, state)}

      {:error, changeset} ->
        state = %State{state | post_changeset: changeset, body: update_body}
        {:noreply, assign(socket, :state, state)}
    end
  end

  def handle_event("switch_edit", _params, %{assigns: %{state: state}} = socket) do
    state = %State{state | edit: not state.edit}
    {:noreply, assign(socket, :state, state)}
  end

  defp markdown_textarea_component(form, state, socket) do
    live_component(socket, LeapWeb.Components.MarkdownTextarea,
      id: "#{state.component_id}_body",
      debounce: state.debounce,
      form: form,
      field: :body,
      value: state.body
    )
  end

  defp patch_post_body(update, body) do
    """
    #### _UPDATE #{Timex.now() |> Timex.to_date() |> Timex.format!("{D}-{Mshort}-{YYYY}")}_


    #{update}

    ---


    #{body}
    """
  end
end
