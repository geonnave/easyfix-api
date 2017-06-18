defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.Cars.Model do
  use Ecto.Migration

  def change do
    create table(:models) do
      add :name, :string
      add :brand_id, references(:brands)

      timestamps()
    end

  end
end
