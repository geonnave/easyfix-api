defmodule EasyFixApi.Repo.Migrations.MakeIndicationCodeUnique do
  use Ecto.Migration

  def change do
    create unique_index(:indication_codes, [:code])
  end
end
