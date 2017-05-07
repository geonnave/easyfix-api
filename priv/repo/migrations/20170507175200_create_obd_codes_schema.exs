defmodule EasyFixApi.Repo.Migrations.ChangeObdCodesSchema do
  use Ecto.Migration

  def change do
    create table(:obd_codes_obd_codes, prefix: "administrative", primary_key: false) do
      add :code, :string, primary_key: true
      add :description, :string

      timestamps()
    end
  end
end
