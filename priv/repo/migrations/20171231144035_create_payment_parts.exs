defmodule EasyFixApi.Repo.Migrations.CreatePaymentParts do
  use Ecto.Migration

  def change do
    create table(:payment_parts) do
      add :quantity, :integer
      add :price, :integer
      add :part_id, references(:parts, on_delete: :nothing)
      add :payment_id, references(:payments, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:payment_parts, [:part_id])
    create index(:payment_parts, [:payment_id])
  end
end
