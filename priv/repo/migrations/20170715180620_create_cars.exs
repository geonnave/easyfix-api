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

    create table(:vehicles) do
      add :production_year, :string
      add :model_year, :string
      add :plate, :string
      add :vehicle_id_number, :string # chassis
      add :model_id, references(:models)

      timestamps(type: :timestamptz)
    end

    create table(:vehicles_customers) do
      add :vehicle_id, references(:vehicles)
      add :customer_id, references(:customers)
    end

  end
end
