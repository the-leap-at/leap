defmodule LeapWeb.Components.Main.Post.Show.Updates do
  @moduledoc """
  Add updates to posts
  """
  use LeapWeb, :component

  alias Leap.Content

  @delay 1000

  def mount(socket) do
    {:ok, assign(socket, :edit, false)}
  end

  def update(assigns, socket) do
    post_form = post_form(assigns.id, assigns.state.post_changeset)

    assigns = Map.merge(assigns, %{post_form: post_form})

    {:ok, assign(socket, assigns)}
  end

  def handle_event(
        "validate_post",
        %{"post" => post_params},
        %{assigns: %{state: state}} = socket
      ) do
    delay_send_to_main(@delay, :validate_publish_post, post_params, state)

    {:noreply, socket}
  end

  def handle_event(
        "publish_update",
        %{"post" => %{"body" => update_body}},
        %{assigns: %{state: state}} = socket
      ) do
    post_params = %{"body" => patch_post_body(update_body, state.post.body)}

    if state.post_changeset.valid? do
      send_to_main(:publish_post, post_params, state)

      {:noreply, assign(socket, :edit, false)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("switch_edit", _params, %{assigns: %{edit: edit}} = socket) do
    {:noreply, assign(socket, :edit, not edit)}
  end

  defp patch_post_body(update, body) do
    """
    #### _UPDATE #{Timex.now() |> Timex.to_date() |> Timex.format!("{D}-{Mshort}-{YYYY}")}_


    #{update}

    ---


    #{body}
    """
  end

  defp post_form(component_id, %Ecto.Changeset{} = changeset) do
    form_for(changeset, "#",
      phx_change: "validate_post",
      phx_submit: "publish_update",
      phx_target: "#" <> component_id
    )
  end

  defp markdown_textarea_component(id, post_form, state, socket) do
    live_component(socket, LeapWeb.Components.Shared.MarkdownTextarea,
      id: "#{id}_body",
      post_form: post_form,
      field: :body,
      # TODO find a way not to put empty space inside body
      # Strange behaviour when nil
      value: Content.get_change(state.post_changeset, :body, "  ")
    )
  end
end
