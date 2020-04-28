defmodule Leap.Repo.Migrations.CreatePostsCategoriesTable do
  use Ecto.Migration

  def change do
    create table(:posts_categories) do
      add :post_id, references(:posts, on_delete: :delete_all)
      add :category_id, references(:categories, on_delete: :delete_all)

      timestamps()
    end

    create index(:posts_categories, [:post_id])
    create index(:posts_categories, [:category_id])

    create unique_index(:posts_categories, [:post_id, :category_id], name: :unique_post_category)
  end
end
