defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.Cars do
  use Ecto.Migration

  def change do
    create table(:brands) do
      add :name, :string

      timestamps(type: :timestamptz)
    end

    create table(:models) do
      add :name, :string
      add :brand_id, references(:brands)

      timestamps(type: :timestamptz)
    end

  end
end
