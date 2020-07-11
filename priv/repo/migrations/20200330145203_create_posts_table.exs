defmodule Leap.Repo.Migrations.CreatePostsTable do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :body, :text
      add :state, :string, null: false, default: "new"
      add :type, :string, null: false

      add :category_id, references(:categories)
      add :user_id, references(:users)

      timestamps()
    end

    create index(:posts, [:state])
    create index(:posts, [:type])
    create index(:posts, [:category_id])
    create index(:posts, [:user_id])
  end
end
