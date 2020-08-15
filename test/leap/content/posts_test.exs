defmodule Leap.Content.PostsTest do
  use Leap.DataCase

  alias Leap.Content.Posts
  alias Leap.Content.Schema.Post

  describe "transition_state_to/3" do
    test "transitions post between correct states" do
      user = insert(:user)

      %Post{id: post_id} = post = insert(:question, user: user, state: :new)

      assert {:ok, %Post{id: ^post_id, state: :draft} = post} =
               Posts.transition_state_to(user, post, :draft)

      assert {:ok, %Post{id: ^post_id, state: :published}} =
               Posts.transition_state_to(user, post, :published)
    end

    test "returns changeset error when trying to transition to a wrong state" do
      user = insert(:user)
      post = insert(:question, user: user, state: :new)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Posts.transition_state_to(user, post, :published)

      refute changeset.valid?
      assert [state: _error] = changeset.errors
    end

    test "only the post creator can transition the state" do
      post = insert(:question, state: :new)
      user = insert(:user)

      assert {:error, :unauthorized} = Posts.transition_state_to(user, post, :draft)
    end
  end

  describe "update/3" do
    test "updating a new post transitions its state to draft" do
      user = insert(:user)
      post = insert(:question, user: user, state: :new)

      assert {:ok, %Post{body: "hello world", state: :draft}} =
               Posts.update(user, post, %{body: "hello world"})
    end

    test "only the post creator can update the post" do
      post = insert(:question, state: :new)
      user = insert(:user)

      assert {:error, :unauthorized} = Posts.update(user, post, %{body: "hello world"})
    end
  end

  describe "publish/3" do
    test "updates the post with valid attributes and transitions the state to published" do
      user = insert(:user)
      post = insert(:question, user: user, state: :draft)

      assert {:ok, %Post{body: "hello world", state: :published}} =
               Posts.publish(user, post, %{body: "hello world"})
    end

    test "only the post creator can publish the post" do
      post = insert(:question, state: :draft)
      user = insert(:user)

      assert {:error, :unauthorized} = Posts.publish(user, post, %{body: "hello world"})
    end
  end

  describe "crete!/1" do
    test "creates a post with valid attributes" do
      user = insert(:user)

      assert %Post{} = Posts.create!(%{user_id: user.id, type: :question})
    end
  end

  describe "add_parent!/2" do
    test "adds parent for a post" do
      post = insert(:learn_path, parents: []) |> Repo.preload(:parents)
      assert length(post.parents) == 0
      parent = insert(:question)

      Posts.add_parent!(post, parent)

      post = Post |> Repo.get!(post.id) |> Repo.preload(:parents)
      assert length(post.parents) == 1
    end
  end

  describe "add_child!/2" do
    test "adds child for a post" do
      post = insert(:question, children: []) |> Repo.preload(:children)
      assert length(post.children) == 0
      child = insert(:learn_path)

      Posts.add_child!(post, child)

      post = Post |> Repo.get!(post.id) |> Repo.preload(:children)
      assert length(post.children) == 1
    end
  end
end
