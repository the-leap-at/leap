defmodule Leap.Repo.Migrations.FillCategories do
  use Ecto.Migration

  def up do
    execute("""
    CREATE INDEX categories_trgm_index ON categories USING GIN (to_tsvector('english', coalesce(name, ' ')))
    """)
  end

  def down do
    execute("DROP INDEX categories_trgm_index")
  end
end
