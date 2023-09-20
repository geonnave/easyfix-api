defmodule EasyFixApi.Repo.Migrations.ChangePaymentDiscount do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      add :applied_voucher_id, references(:indication_codes)
    end
  end
end
