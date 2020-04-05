defmodule Leap.Repo.Migrations.CreatePathsTable do
  use Ecto.Migration

  def change do
    create table(:paths) do
      add :title, :string
      add :description, :text
      add :state, :text, null: false, default: "new"

      timestamps()
    end
  end
end
