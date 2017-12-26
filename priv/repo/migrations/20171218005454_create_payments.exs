defmodule EasyFixApi.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :iugu_invoice_id, :string
      add :state, :string

      add :amount, :integer
      add :payment_method, :string
      add :installments, :integer
      add :iugu_fee, :decimal
      add :factoring_fee, :decimal

      add :quote_id, references(:quotes, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:payments, [:quote_id])
  end
end
