defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.Payments do
  use Ecto.Migration

  def change do
    create table(:banks) do
      add :code, :string
      add :name, :string

      timestamps(type: :timestamptz)
    end

    create table(:bank_accounts) do
      add :agency, :string
      add :number, :string
      add :bank_id, references(:banks)

      timestamps(type: :timestamptz)
    end

    alter table(:garages) do
      add :bank_account_id, references(:bank_accounts)
    end
  end
end
