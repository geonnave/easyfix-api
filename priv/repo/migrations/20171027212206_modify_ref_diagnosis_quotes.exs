defmodule EasyFixApi.Repo.Migrations.ModifyRefDiagnosisQuotes do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE quotes DROP CONSTRAINT quotes_diagnosis_id_fkey"
    alter table(:quotes) do
      modify :diagnosis_id, references(:diagnosis, on_delete: :delete_all)
    end
  end

  def down do
    execute "ALTER TABLE quotes DROP CONSTRAINT quotes_diagnosis_id_fkey"
    alter table(:quotes) do
      modify :diagnosis_id, references(:diagnosis, on_delete: :nilify_all)
    end
  end
end
