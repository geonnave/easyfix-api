defmodule EasyFixApi.Repo.Migrations.AddPaymentDiscount do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      add :discount, :integer
    end
  end
end
