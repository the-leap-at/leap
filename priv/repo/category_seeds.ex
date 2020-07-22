#     mix run priv/repo/category_seeds.exs

alias Leap.Repo
alias Leap.Group.Schema.Category

now = DateTime.utc_now() |> DateTime.to_naive() |> NaiveDateTime.truncate(:second)

categories =
  for category_name <- Category.category_name(),
      do: [name: category_name, inserted_at: now, updated_at: now]

Repo.insert_all(Category, categories, on_conflict: :nothing)
