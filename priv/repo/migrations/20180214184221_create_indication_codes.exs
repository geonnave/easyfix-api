defmodule EasyFixApi.Repo.Migrations.CreateIndicationCodes do
  use Ecto.Migration

  def change do
    create table(:indication_codes) do
      add :code, :string
      add :type, :string
      add :date_used, :utc_datetime
      add :customer_id, references(:customers, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end

    create index(:indication_codes, [:customer_id])
  end
end
