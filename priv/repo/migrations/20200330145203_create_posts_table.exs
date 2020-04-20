defmodule Leap.Repo.Migrations.CreatePostsTable do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :body, :text
      add :state, :text, null: false, default: "new"

      timestamps()
    end
  end
end
