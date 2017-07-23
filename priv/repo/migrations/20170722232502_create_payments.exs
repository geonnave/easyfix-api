defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.Payments do
  use Ecto.Migration

  def change do
    create table(:banks) do
      add :code, :string
      add :name, :string

      timestamps()
    end

  end
end
