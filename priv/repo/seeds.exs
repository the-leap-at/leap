# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Leap.Repo.insert!(%Leap.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Leap.Repo
alias Leap.Group.Schema.Category

now = DateTime.utc_now() |> DateTime.to_naive() |> NaiveDateTime.truncate(:second)

categories =
  for category_name <- Category.category_name(),
      do: [name: category_name, inserted_at: now, updated_at: now]

Repo.insert_all(Category, categories, on_conflict: :nothing)
