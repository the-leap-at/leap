defmodule Leap.Repo.Migrations.CreatePostsTable do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :body, :text
      add :state, :string, null: false, default: "new"
      add :type, :string, null: false

      timestamps()
    end

    create index(:posts, [:state])
    create index(:posts, [:type])
  end
end
