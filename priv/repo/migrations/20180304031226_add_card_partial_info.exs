defmodule EasyFixApi.Repo.Migrations.AddCardPartialInfo do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      add :card_brand, :string
      add :card_last_digitis, :string
    end
  end
end
