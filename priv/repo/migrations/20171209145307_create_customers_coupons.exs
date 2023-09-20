defmodule EasyFixApi.Repo.Migrations.CreateCustomersCoupons do
  use Ecto.Migration

  def change do
    create table(:customers_coupons) do
      add :quantity, :integer
      add :expiration_date, :utc_datetime
      add :customer_id, references(:customers, on_delete: :nothing)
      add :coupon_id, references(:coupons, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:customers_coupons, [:customer_id])
    create index(:customers_coupons, [:coupon_id])
  end
end
