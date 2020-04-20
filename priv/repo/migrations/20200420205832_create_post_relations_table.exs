defmodule Leap.Repo.Migrations.CreatePostRelationsTable do
  use Ecto.Migration

  def change do
    create table(:post_relations) do
      add :parent_id, references(:posts)
      add :child_id, references(:posts)

      timestamps()
    end

    create index(:post_relations, [:parent_id])
    create index(:post_relations, [:child_id])
  end
end
