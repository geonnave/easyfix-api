defmodule EasyFixApi.Repo.Migrations.FixIndicationCodeUniqueness do
  use Ecto.Migration

  def change do
    # this column *will* have duplicates, as its table is used for storing 
    # a number of discount codes a customer has available
    drop unique_index(:indication_codes, [:code])

    # no customer
    create unique_index(:customers, [:indication_code])
  end
end
