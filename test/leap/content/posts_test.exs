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
end
