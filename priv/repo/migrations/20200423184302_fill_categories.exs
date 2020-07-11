defmodule Leap.Repo.Migrations.FillCategories do
  use Ecto.Migration

  def up do
    execute("""
    INSERT INTO categories(name, inserted_at, updated_at)
     VALUES
      ('technology', now(), now()),
      ('science', now(), now()),
      ('design', now(), now()),
      ('education', now(), now()),
      ('psychology', now(), now()),
      ('literature', now(), now()),
      ('media', now(), now()),
      ('art', now(), now()),
      ('crafts', now(), now()),
      ('architecture', now(), now()),
      ('food', now(), now()),
      ('health', now(), now()),
      ('sports', now(), now()),
      ('travel', now(), now()),
      ('business', now(), now()),
      ('services', now(), now()),
      ('finance', now(), now()),
      ('legal', now(), now()),
      ('management', now(), now()),
      ('marketing', now(), now()),
      ('sales', now(), now()),
      ('politics', now(), now()),
      ('other', now(), now());
    """)

    execute("""
    CREATE INDEX categories_trgm_index ON categories USING GIN (to_tsvector('english', coalesce(name, ' ')))
    """)
  end

  def down do
    execute("DROP INDEX categories_trgm_index")
    nil
  end
end
