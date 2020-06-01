defmodule Leap.Repo.Migrations.AddPictureAndStateToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :picture_url, :string
      add :state, :string, null: false, default: "new"
      add :display_name, :string
    end

    create unique_index(:users, [:display_name])
  end
end
