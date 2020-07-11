defmodule LeapWeb.Components.Container.Question do
  use LeapWeb, :component

  alias Leap.Content
  alias Leap.Content.Schema.Post
  alias Leap.Accounts.Schema.User

  def mount(socket) do
    {:ok, socket, temporary_assigns: [answers: []]}
  end

  def update(%{action: :init} = assigns, socket) do
    question = get_question(assigns.post_id)

    assigns = Map.merge(assigns, %{question: question, answers: question.children})
    {:ok, assign(socket, assigns)}
  end

  def handle_event(
        "add_answer",
        _params,
        %{
          assigns: %{
            current_user: %User{id: current_user_id},
            question: %Post{category_id: category_id}
          }
        } = socket
      ) do
    answer =
      %{type: :learn_path, user_id: current_user_id, category_id: category_id}
      |> Content.create_post!()
      |> Content.add_post_parent!(socket.assigns.question)
      |> Content.with_preloads([:category, :parents])

    socket = assign(socket, :answers, [answer])

    {:noreply, socket}
  end

  def handle_event("add_answer", _params, socket) do
    {:noreply, redirect(socket, to: "/session/new")}
  end

  defp post_component(current_user, post, socket) do
    live_component(socket, LeapWeb.Components.Main.Post,
      id: "post_#{to_string(post.id)}",
      action: :init,
      current_user: current_user,
      post: post
    )
  end

  defp get_question(post_id) do
    Post
    |> Content.get_by!(id: post_id, type: :question)
    |> Content.with_preloads([:category, [children: [:category, :parents]]])
  end

  defp display_answer(_current_user, %Post{state: :published}), do: true
  defp display_answer(%User{id: user_id}, %Post{user_id: user_id}), do: true
  defp display_answer(_current_user, _post), do: false

  defp display_add_answer(%User{id: user_id}, _question, posts) do
    not Enum.any?(posts, &(&1.user_id == user_id && &1.state != :published))
  end

  defp display_add_answer(_current_user, %Post{state: :published}, _posts), do: true
  defp display_add_answer(_current_user, _question, _posts), do: false
end
