defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.StaticData.Brand do
  use Ecto.Migration

  def change do
    create table(:static_data_brands) do
      add :name, :string

      timestamps()
    end

  end
end
