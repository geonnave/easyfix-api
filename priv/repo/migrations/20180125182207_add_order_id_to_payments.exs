defmodule EasyFixApi.Repo.Migrations.AddOrderIdToPayments do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      add :order_id, references(:orders, on_delete: :nilify_all)
    end
  end
end
