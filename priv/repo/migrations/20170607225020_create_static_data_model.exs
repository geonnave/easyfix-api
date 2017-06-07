defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.StaticData.Model do
  use Ecto.Migration

  def change do
    create table(:static_data_models) do
      add :name, :string
      add :brand_id, references(:static_data_brands, on_delete: :nothing)

      timestamps()
    end

    create index(:static_data_models, [:brand_id])
  end
end
