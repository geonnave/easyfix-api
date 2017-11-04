defmodule EasyFixApi.Repo.Migrations.AddQuotePartComment do
  use Ecto.Migration

  def change do
    alter table(:quotes) do
      add :comment, :string
    end
    alter table(:quotes_parts) do
      add :comment, :string
    end
  end
end
