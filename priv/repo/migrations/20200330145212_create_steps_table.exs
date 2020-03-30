defmodule Leap.Repo.Migrations.CreateStepsTable do
  use Ecto.Migration

  def change do
    create table(:steps) do
      add :title, :string
      add :position, :integer
      add :description, :text
      add :url, :string
      add :pricing, :string

      add :path_id, references(:paths, on_delete: :delete_all)

      timestamps()
    end

    create index(:steps, [:path_id])
  end
end
