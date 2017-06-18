defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.Cars.Brand do
  use Ecto.Migration

  def change do
    create table(:brands) do
      add :name, :string

      timestamps()
    end

    create table(:models) do
      add :name, :string
      add :brand_id, references(:brands)

      timestamps()
    end

  end
end
