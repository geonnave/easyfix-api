defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.Accounts do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :password, :string
      add :password_hash, :string

      timestamps(type: :timestamptz)
    end
    create unique_index(:users, [:email])

    create table(:garages) do
      add :name, :string
      add :owner_name, :string
      add :phone, :string
      add :cnpj, :string
      add :user_id, references(:users)
      add :bank_account_id, references(:bank_accounts)

      timestamps(type: :timestamptz)
    end

    create table(:garages_garage_categories, primary_key: false) do
      add :garage_id, references(:garages)
      add :garage_category_id, references(:garage_categories)
    end
    create unique_index(:garages_garage_categories, [:garage_id, :garage_category_id])

    create table(:customers) do
      add :name, :string
      add :phone, :string
      add :cpf, :string
      add :accept_easyfix_policy, :utc_datetime
      add :user_id, references(:users)

      timestamps(type: :timestamptz)
    end
  end
end
