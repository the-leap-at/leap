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
      fav_categories: build_list(Enum.random(1..5), :category)
    }
  end

  def category_factory do
    %Category{
      name: Faker.Internet.slug()
    }
  end

  def post_factory do
    %Post{
      title: Faker.Lorem.sentence(),
      body: Faker.Lorem.paragraph(2..10),
      state: :published,
      category: build(:category),
      user: build(:user)
    }
  end

  def learn_path_factory do
    %Post{
      title: Faker.Lorem.sentence(),
      body: Faker.Lorem.paragraph(2..10),
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
      body: Faker.Lorem.paragraph(2..10),
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
