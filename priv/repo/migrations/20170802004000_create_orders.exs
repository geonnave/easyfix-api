defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.Orders do
  use Ecto.Migration

  def change do
    create table(:diagnosis) do
      add :accepts_used_parts, :boolean, default: false, null: false
      add :need_tow_truck, :boolean, default: false, null: false
      add :status, :string
      add :comment, :string
      add :expiration_date, :utc_datetime

      add :vehicle_id, references(:vehicles)

      timestamps(type: :timestamptz)
    end

    create table(:diagnosis_parts) do
      add :diagnosis_id, references(:diagnosis)
      add :part_id, references(:parts)
      add :quantity, :integer

      timestamps(type: :timestamptz)
    end
    create unique_index(:diagnosis_parts, [:diagnosis_id, :part_id])

    EasyFixApi.Accounts.UserTypeEnum.create_type
    create table(:budgets) do
      add :service_cost, :integer
      add :status, :string
      add :sub_status, :string

      add :opening_date, :utc_datetime
      add :due_date, :utc_datetime
      add :conclusion_date, :utc_datetime

      add :issuer_type, :user_type
      add :issuer_id, references(:users)

      add :diagnosis_id, references(:diagnosis)

      timestamps(type: :timestamptz)
    end
    # create unique_index(:budgets, [:issuer_id, :issuer_type])

    create table(:budgets_parts) do
      add :budget_id, references(:budgets)
      add :part_id, references(:parts)
      add :quantity, :integer
      add :price, :integer

      timestamps(type: :timestamptz)
    end
    create unique_index(:budgets_parts, [:budget_id, :part_id])

    EasyFixApi.Orders.StateEnum.create_type
    create table(:orders) do
      add :state, :order_state
      add :state_due_date, :utc_datetime
      # add :sub_state, :string
      # add :opening_date, :utc_datetime
      add :conclusion_date, :utc_datetime

      add :diagnosis_id, references(:diagnosis)
      add :customer_id, references(:customers)

      timestamps(type: :timestamptz)
    end
  end
end
