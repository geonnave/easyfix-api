defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.Garages do
  use Ecto.Migration

  def change do
    create table(:garages) do
      add :name, :string
      add :owner_name, :string
      add :phone, :string
      add :cnpj, :string
      add :user_id, references(:users)

      timestamps()
    end

    create table(:garages_garage_categories, primary_key: false) do
      add :garage_id, references(:garages)
      add :garage_category_id, references(:garage_categories)
    end

    create unique_index(:garages_garage_categories, [:garage_id, :garage_category_id])

  end
end
