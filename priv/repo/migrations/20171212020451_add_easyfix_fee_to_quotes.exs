defmodule EasyFixApi.Repo.Migrations.AddEasyfixFeeToQuotes do
  use Ecto.Migration

  def change do
    alter table(:quotes) do
      add :easyfix_customer_fee, :decimal
    end
  end
end
