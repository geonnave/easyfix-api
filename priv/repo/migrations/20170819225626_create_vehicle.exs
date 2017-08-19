defmodule EasyFixApi.Repo.Migrations.CreateVehicle do
  use Ecto.Migration

  def change do
    create table(:vehicle) do
      add :production_year, :string
      add :model_year, :string
      add :plate, :string

      timestamps()
    end

  end
end
