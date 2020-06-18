defmodule LeapWeb.Components.Container.Question do
  use LeapWeb, :component

  alias Leap.Content
  alias Leap.Content.Schema.Post

  def mount(socket) do
    {:ok, socket, temporary_assigns: [answers: []]}
  end

  def update(%{action: :init} = assigns, socket) do
    question = get_question(assigns.post_id)

    assigns = Map.merge(assigns, %{question: question, answers: question.children})
    {:ok, assign(socket, assigns)}
  end

  def handle_event("add_answer", _params, socket) do
    answer =
      %{type: :learn_path}
      |> Content.create_post!()
      |> Content.add_post_parent!(socket.assigns.question)

    # TODO verify if refetch still needed after read_after_writes
    answer = get_answer(answer.id)

    socket = assign(socket, :answers, [answer])

    {:noreply, socket}
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

  defp get_answer(post_id) do
    Post
    |> Content.get!(post_id)
    |> Content.with_preloads([:category, :parents])
  end
end
