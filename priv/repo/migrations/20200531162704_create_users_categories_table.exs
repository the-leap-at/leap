defmodule Leap.Repo.Migrations.CreateUsersCategoriesTable do
  use Ecto.Migration

  def change do
    create table(:users_categories) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :category_id, references(:categories, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:users_categories, [:user_id, :category_id], name: :unique_user_category)
  end
end
