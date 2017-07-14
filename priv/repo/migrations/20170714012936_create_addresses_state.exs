defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.Addresses do
  use Ecto.Migration

  def change do
    create table(:states) do
      add :name, :string

      timestamps()
    end

    create table(:cities) do
      add :name, :string
      add :state_id, references(:states)

      timestamps()
    end

    create table(:addresses) do
      add :postal_code, :string
      add :address_line1, :string
      add :address_line2, :string
      add :neighborhood, :string
      add :city_id, references(:cities)

      timestamps()
    end
  end
end
