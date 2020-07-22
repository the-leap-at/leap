defmodule Leap.Group.CategoriesTest do
  use Leap.DataCase

  alias Leap.Group.Categories

  describe "search/1" do
    test "searches by term and returns categories" do
      category = insert(:category, name: "technology")
      [result] = Categories.search("tech")
      assert category.id == result.id
    end

    test "returns multiple categories starting with the same term" do
      cat_1 = insert(:category, name: "abcx")
      cat_2 = insert(:category, name: "abcy")
      _cat_3 = insert(:category, name: "bcxy")

      result = Categories.search("abc")

      assert length(result) == 2

      for category <- result do
        assert category.id in [cat_1.id, cat_2.id]
      end
    end
  end

  describe "add_user_fav!/1" do
    test "adds a favourite category for a user" do
      user = insert(:user, fav_categories: [])
      category = insert(:category, name: "technology")

      Categories.add_user_fav!(%{user_id: user.id, category_id: category.id})

      user = Repo.preload(user, :fav_categories, force: true)
      [user_fav_category] = user.fav_categories
      assert user_fav_category.id == category.id
    end
  end

  describe "remove_user_fav!/1" do
    test "removes a favourite category for a user" do
      cat_1 = insert(:category, name: "technology")
      cat_2 = insert(:category, name: "science")
      cat_3 = insert(:category, name: "design")

      user = insert(:user, fav_categories: [cat_1, cat_2, cat_3])

      Categories.remove_user_fav!(%{user_id: user.id, category_id: cat_3.id})

      user = Repo.preload(user, :fav_categories, force: true)
      assert length(user.fav_categories) == 2

      for category <- user.fav_categories do
        assert category.id in [cat_1.id, cat_2.id]
      end
    end
  end
end
