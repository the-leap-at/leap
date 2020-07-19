defmodule Leap.Factory do
  use ExMachina.Ecto, repo: Leap.Repo

  alias Leap.Accounts.Schema.User
  alias Leap.Group.Schema.Category
  alias Leap.Content.Schema.Post

  def user_factory do
    %User{
      email: Faker.Internet.email(),
      picture_url: Faker.Internet.url(),
      state: :onboarded,
      display_name: Faker.Internet.user_name(),
      fav_categories: random_categories()
    }
  end

  defp random_categories do
    random_size = Enum.random(1..length(Category.category_name()))

    Category.category_name()
    |> Enum.take_random(random_size)
    |> Enum.map(&build(:category, %{name: &1}))
  end

  def category_factory do
    %Category{
      name: Enum.random(Category.category_name())
    }
  end

  def post_factory do
    %Post{
      title: Faker.Lorem.sentence(),
      body: Faker.Lorem.paragraphs(),
      state: :published,
      category: build(:category),
      user: build(:user)
    }
  end

  def leran_path_factory do
    %Post{
      title: Faker.Lorem.sentence(),
      body: Faker.Lorem.paragraphs(),
      type: :learn_path,
      state: :published,
      parents: random_posts(:question),
      category: build(:category),
      user: build(:user)
    }
  end

  def question_factory do
    %Post{
      title: Faker.Lorem.sentence(5, "?"),
      body: Faker.Lorem.paragraphs(),
      type: :question,
      state: :published,
      children: random_posts(:learn_path),
      category: build(:category),
      user: build(:user)
    }
  end

  defp random_posts(type) do
    Enum.random(1..5)
    |> build_list(:post, %{type: type})
  end
end
