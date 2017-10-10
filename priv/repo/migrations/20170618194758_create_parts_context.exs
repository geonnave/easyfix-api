defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.Parts do
  use Ecto.Migration

  def change do
    create table(:garage_categories) do
      add :name, :string

      timestamps(type: :timestamptz)
    end
    create index(:garage_categories, [:name], unique: true)

    create table(:part_systems) do
      add :name, :string

      timestamps(type: :timestamptz)
    end
    create index(:part_systems, [:name], unique: true)

    create table(:part_groups) do
      add :name, :string
      add :part_system_id, references(:part_systems)

      timestamps(type: :timestamptz)
    end
    create index(:part_groups, [:name], unique: true)

    create table(:part_sub_groups) do
      add :name, :string
      add :part_group_id, references(:part_groups)

      timestamps(type: :timestamptz)
    end
    create index(:part_sub_groups, [:name], unique: true)

    create table(:parts) do
      add :name, :string
      add :repair_by_fixer, :boolean
      add :part_sub_group_id, references(:part_sub_groups)
      add :garage_category_id, references(:garage_categories)

      timestamps(type: :timestamptz)
    end
  end
end
