defmodule Leap.Repo.Migrations.AddDeferrableConstraintToStepsPosition do
  use Ecto.Migration

  def up do
    execute(add_deferrable_constraint())
  end

  def down do
    execute(drop_constraint())
  end

  def add_deferrable_constraint do
    """
    ALTER TABLE steps ADD CONSTRAINT unique_position_for_path UNIQUE (path_id, position) DEFERRABLE INITIALLY DEFERRED;
    """
  end

  def drop_constraint do
    """
    ALTER TABLE steps DROP CONSTRAINT unique_position_for_path;
    """
  end
end
