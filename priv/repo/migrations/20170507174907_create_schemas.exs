defmodule EasyFixApi.Repo.Migrations.CreateSchemas do
  use Ecto.Migration

  def up do
    execute "CREATE SCHEMA administrative;"
    execute "CREATE SCHEMA operational;"
  end

  def down do
    execute "DROP SCHEMA administrative;"
    execute "DROP SCHEMA operational;"
  end
end
