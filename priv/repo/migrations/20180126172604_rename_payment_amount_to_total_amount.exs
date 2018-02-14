defmodule EasyFixApi.Repo.Migrations.RenamePaymentAmountToTotalAmount do
  use Ecto.Migration

  def change do
    rename table(:payments), :amount, to: :total_amount
  end
end
