defmodule Leap.Repo.Migrations.CreatePostRelationsTable do
  use Ecto.Migration

  def change do
    create table(:post_relations) do
      add :parent_id, references(:posts, on_delete: :delete_all)
      add :child_id, references(:posts, on_delete: :delete_all)

      timestamps()
    end

    create index(:post_relations, [:parent_id])
    create index(:post_relations, [:child_id])
    create unique_index(:post_relations, [:parent_id, :child_id], name: :unique_parent_child)
  end
end
