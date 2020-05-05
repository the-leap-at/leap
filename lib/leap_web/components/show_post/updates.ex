defmodule LeapWeb.Components.ShowPost.Updates do
  @moduledoc """
  Add updates to posts
  """
  use LeapWeb, :component
  use TypedStruct

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    form =
      form_for(assigns.state.post_changeset, "#",
        phx_submit: "publish_update",
        phx_target: "#" <> assigns.id
      )

    edit = !assigns.state.post_changeset.valid?
    assigns = Map.merge(assigns, %{form: form, edit: edit})

    {:ok, assign(socket, assigns)}
  end

  def handle_event(
        "publish_update",
        %{"post" => %{"body" => update_body}},
        socket
      ) do
    post_params = %{"body" => patch_post_body(update_body, socket.assigns.state.post.body)}

    send(self(), {:publish_post, post_params})

    {:noreply, socket}
  end

  def handle_event("switch_edit", _params, %{assigns: %{edit: edit}} = socket) do
    {:noreply, assign(socket, :edit, not edit)}
  end

  defp markdown_textarea_component(id, form, state, socket) do
    live_component(socket, LeapWeb.Components.MarkdownTextarea,
      id: "#{id}_body",
      form: form,
      state: state,
      field: :body,
      value: ""
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
