defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.Parts do
  use Ecto.Migration

  def change do
    create table(:garage_categories) do
      add :name, :string

      timestamps()
    end

    create table(:part_systems) do
      add :name, :string

      timestamps()
    end

    create table(:part_groups) do
      add :name, :string
      add :part_system_id, references(:part_systems)

      timestamps()
    end

    create table(:part_sub_groups) do
      add :name, :string
      add :part_group_id, references(:part_groups)

      timestamps()
    end

    create table(:parts) do
      add :name, :string
      add :part_sub_group_id, references(:part_sub_groups)
      add :garage_category_id, references(:garage_categories)

      timestamps()
    end

  end
end
