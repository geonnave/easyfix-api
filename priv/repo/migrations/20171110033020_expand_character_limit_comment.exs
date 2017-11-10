defmodule EasyFixApi.Repo.Migrations.ExpandCharacterLimitComment do
  use Ecto.Migration

  def change do
    alter table(:diagnosis) do
      modify :comment, :text
    end
    alter table(:diagnosis_parts) do
      modify :comment, :text
    end
    alter table(:quotes) do
      modify :comment, :text
    end
    alter table(:quotes_parts) do
      modify :comment, :text
    end
  end
end
