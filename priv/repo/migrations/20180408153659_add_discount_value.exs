defmodule EasyFixApi.Repo.Migrations.AddDiscountValue do
  use Ecto.Migration

  def change do
    alter table(:indication_codes) do
      add :discount, :integer, default: 30_00
    end
  end
end
