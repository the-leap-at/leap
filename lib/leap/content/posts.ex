defmodule Leap.Content.Posts do
  @moduledoc """
  Functions specific to Posts.
  The functions that are not exposed throught the context (defdelegate) are only context internal
  """
  alias Leap.Repo
  alias Leap.Content
  alias Leap.Content.Schema.Post
  alias Leap.Accounts.Schema.User

  @editable_state [:draft, :published]
  @publishable_state [:draft, :published]

  # USER SCOPED

  @doc "Machinery wrapper that converts errors to changest"
  @spec transition_state_to(User.t(), Post.t(), next_state :: atom()) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  def transition_state_to(%User{} = user, %Post{} = post, next_state) when is_atom(next_state) do
    with :ok <- Bodyguard.permit(Content, :post_mutation, user, post) do
      case Machinery.transition_to(post, Post.StateMachine, next_state) do
        {:ok, post} ->
          {:ok, post}

        {:error, cause} ->
          changeset = Post.changeset_state_transition_error(post, %{state: next_state}, cause)
          {:error, changeset}
      end
    end
  end

  @spec update(User.t(), Post.t(), attrs :: map()) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  @doc "when updating a new post, it transitions to draft state"
  def update(%User{} = user, %Post{state: :new} = post, attrs) do
    with {:ok, post} = transition_state_to(user, post, :draft) do
      update(user, post, attrs)
    end
  end

  def update(%User{} = user, %Post{state: state} = post, attrs) when state in @editable_state do
    with :ok <- Bodyguard.permit(Content, :post_mutation, user, post) do
      post
      |> Post.changeset_update(attrs)
      |> Repo.update()
    end
  end

  @spec update!(User.t(), Post.t(), attrs :: map()) :: Post.t()
  def update!(%User{} = user, %Post{} = post, attrs) do
    Bodyguard.permit!(Content, :post_mutation, user, post)

    post
    |> Post.changeset_update(attrs)
    |> Repo.update!()
  end

  @spec publish(User.t(), Post.t(), attrs :: map()) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t(Post.t())}
  def publish(%User{} = user, %Post{state: state} = post, attrs)
      when state in @publishable_state do
    with :ok <- Bodyguard.permit(Content, :post_mutation, user, post),
         changeset = Post.changeset_publish(post, attrs),
         {:ok, post} <- Repo.update(changeset),
         {:ok, post} <- transition_state_to_published(user, post) do
      {:ok, post}
    end
  end

  defp transition_state_to_published(_user, %Post{state: :published} = post), do: {:ok, post}
  defp transition_state_to_published(user, post), do: transition_state_to(user, post, :published)

  # UNSCOPED

  @spec create!(attrs :: map()) :: Post.t()
  def create!(attrs) do
    %Post{}
    |> Post.changeset_create(attrs)
    |> Repo.insert!()
  end

  @doc "Function used by Machinery to persist the state update"
  @spec update_state!(Post.t(), next_state :: Post.StateEnum.t()) :: Post.t()
  def update_state!(%Post{} = post, next_state) do
    post
    |> Post.changeset_state_transition(%{state: next_state})
    |> Repo.update!()
  end

  @spec add_parent!(Post.t(), Post.t()) :: Post.t()
  def add_parent!(post, parent) do
    post = Repo.preload(post, :parents)

    post
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:parents, [parent | post.parents])
    |> Repo.update!()
  end

  @spec add_child!(Post.t(), Post.t()) :: Post.t()
  def add_child!(post, child) do
    post = Repo.preload(post, :children)

    post
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:children, [child | post.children])
    |> Repo.update!()
  end

  @spec validate_publish(Post.t()) :: Ecto.Changeset.t(Post.t())
  def validate_publish(%Post{} = post, attrs \\ %{}) do
    post
    |> Post.changeset_publish(attrs)
    |> Map.put(:action, :insert)
  end

  @spec change(Post.t()) :: Ecto.Changeset.t(Post.t())
  def change(%Post{} = post, attrs \\ %{}) do
    Post.changeset_update(post, attrs)
  end
end
