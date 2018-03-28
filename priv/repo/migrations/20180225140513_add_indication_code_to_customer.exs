defmodule EasyFixApi.Repo.Migrations.AddIndicationCodeToCustomer do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add :indication_code, :string # capitalized name + hashid of customer_id
    end
  end
end
