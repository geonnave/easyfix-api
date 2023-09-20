defmodule EasyFixApi.Repo.Migrations.CreateCoupons do
  use Ecto.Migration

  def change do
    create table(:coupons) do
      add :code, :string
      add :type, :string # e.g. easyfix | customer | easyfix_partner
      add :discount, :integer
      add :discount_type, :string # value | percent
      add :description, :string
      add :expiration_date, :utc_datetime
      add :owner_id, references(:customers, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:coupons, [:owner_id])
  end
end
