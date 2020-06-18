defmodule LeapWeb.Components.Main.Post do
  use LeapWeb, :component
  use TypedStruct

  alias LeapWeb.Components.Main.Post.Mutation
  alias Leap.Content
  alias Leap.Content.Schema.Post
  alias Leap.Group
  alias Leap.Group.Schema.Category
  alias Leap.Accounts.Schema.User

  defmodule State do
    @moduledoc false

    @typedoc "Post state"
    typedstruct do
      field :id, String.t(), enforce: true
      field :module, module(), enforce: true
      field :current_user, User.t()
      field :post, Post.t(), enforce: true
      field :post_changeset, Ecto.Changeset.t(Post.t())
      field :post_behaviour, atom(), default: :show_post, enforce: true
      field :categories, [Category.t()], default: []
    end
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{action: :init, id: id, post: post, current_user: current_user}, socket) do
    changeset = Content.change_post(post)

    state = %State{
      id: id,
      module: __MODULE__,
      current_user: current_user,
      post: post,
      post_changeset: changeset,
      post_behaviour: post_behaviour(post),
      categories: Group.all(Category)
    }

    {:ok, assign(socket, :state, state)}
  end

  def update(%{action: action, payload: attrs}, %{assigns: %{state: state}} = socket) do
    mutation = Mutation.commit(action, attrs, state)
    response(mutation, socket)
  end

  defp response({:ok, {%State{} = state, {type, message}}}, socket) do
    send_notification(state.id, type, message)
    {:ok, assign(socket, :state, state)}
  end

  defp response({:ok, %State{} = state}, socket) do
    {:ok, assign(socket, :state, state)}
  end

  defp response({:error, message}, socket) do
    send_notification(socket.assigns.state.id, :danger, message)
    {:ok, socket}
  end

  defp post_behaviour_component(%{post_behaviour: :show_post} = state, socket) do
    live_component(socket, LeapWeb.Components.Main.Post.Show,
      id: "show_post_" <> to_string(state.post.id),
      action: :init,
      state: state
    )
  end

  defp post_behaviour_component(%{post_behaviour: :edit_post} = state, socket) do
    live_component(socket, LeapWeb.Components.Main.Post.Edit,
      id: "edit_post_" <> to_string(state.post.id),
      action: :init,
      state: state
    )
  end

  defp post_behaviour(%Post{state: :new}), do: :edit_post
  defp post_behaviour(%Post{state: :draft}), do: :edit_post
  defp post_behaviour(%Post{state: :published}), do: :show_post
end
