defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.Orders do
  use Ecto.Migration

  def change do
    create table(:diagnostics) do
      add :accepts_used_parts, :boolean, default: false, null: false
      add :need_tow_truck, :boolean, default: false, null: false
      add :status, :string
      add :comment, :string
      add :expiration_date, :utc_datetime

      timestamps(type: :timestamptz)
    end

    create table(:diagnostics_parts) do
      add :diagnostic_id, references(:diagnostics)
      add :part_id, references(:parts)
    end
    create unique_index(:diagnostics_parts, [:diagnostic_id, :part_id])

    create table(:budgets) do
      add :service_cost, :integer
      add :due_date, :utc_datetime
      add :issuer_type, :string
      add :issuer_id, references(:users)
      add :diagnostic_id, references(:diagnostics)

      timestamps(type: :timestamptz)
    end

    create table(:budgets_parts) do
      add :budget_id, references(:budgets)
      add :part_id, references(:parts)
      add :quantity, :integer
      add :price, :integer

      timestamps(type: :timestamptz)
    end
    create unique_index(:budgets_parts, [:budget_id, :part_id])
  end
end
