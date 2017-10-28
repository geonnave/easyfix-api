defmodule EasyFixApi.Repo.Migrations.AddDiagnosisPartComment do
  use Ecto.Migration

  def change do
    alter table(:diagnosis_parts) do
      add :comment, :string
    end
  end
end
