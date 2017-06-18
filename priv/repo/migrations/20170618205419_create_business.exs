defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.Business do
  use Ecto.Migration

  def change do
    create table(:repair_by_fixer_parts) do
      add :part_id, references(:parts)

      timestamps()
    end

  end
end
