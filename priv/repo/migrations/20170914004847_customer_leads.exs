defmodule EasyFixApi.Repo.Migrations.CustomerLeads do
  use Ecto.Migration

  def change do
    create table(:customer_leads) do
      add :name, :string
      add :phone, :string
      add :email, :string

      add :car, :map
      add :address, :map

      timestamps(type: :timestamptz)
    end
  end
end
