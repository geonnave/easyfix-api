defmodule EasyFixApi.Repo.Migrations.DropCouponTables do
  use Ecto.Migration

  def change do
    drop table(:customers_coupons)
    drop table(:coupons)
  end
end
