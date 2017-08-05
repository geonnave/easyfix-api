defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.Orders do
  use Ecto.Migration

  def change do
    create table(:diagnostics) do
      add :accepts_used_parts, :boolean, default: false, null: false
      add :need_tow_truck, :boolean, default: false, null: false
      add :status, :string
      add :comment, :string
      add :expiration_date, :naive_datetime

      timestamps()
    end

    create table(:diagnostics_parts) do
      add :diagnostic_id, references(:diagnostics)
      add :part_id, references(:parts)
    end

    create unique_index(:diagnostics_parts, [:diagnostic_id, :part_id])
  end
end
