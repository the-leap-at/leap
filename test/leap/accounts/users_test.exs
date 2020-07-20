defmodule Leap.Accounts.UsersTest do
  use Leap.DataCase

  alias Leap.Accounts.Users
  alias Leap.Accounts.Schema.User

  describe "fetch_user/1" do
    test "fetches user by email" do
      %User{id: user_id, email: user_email} = insert(:user)
      assert {:ok, %User{id: ^user_id}} = Users.fetch_user(user_email)
    end

    test "returns error if the user is not found" do
      insert(:user, %{email: "user@email.com"})
      assert {:error, _} = Users.fetch_user("other_user@email.com")
    end
  end

  describe "transition_state_to/2" do
    test "transitions user between correct states" do
      %User{id: user_id} = user = insert(:user, state: :new)

      assert {:ok, %User{id: ^user_id, state: :authenticated} = user} =
               Users.transition_state_to(user, :authenticated)

      assert {:ok, %User{id: ^user_id, state: :display_name_set} = user} =
               Users.transition_state_to(user, :display_name_set)

      assert {:ok, %User{id: ^user_id, state: :onboarded} = user} =
               Users.transition_state_to(user, :onboarded)
    end

    test "returns changeset error when trying to transition to a wrong state" do
      user = insert(:user, state: :new)

      assert {:error, %Ecto.Changeset{} = changeset} = Users.transition_state_to(user, :onboarded)

      refute changeset.valid?
      assert [state: _error] = changeset.errors
    end
  end
end
