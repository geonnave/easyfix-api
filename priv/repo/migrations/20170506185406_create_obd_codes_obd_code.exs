defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.OBDCodes.OBDCode do
  use Ecto.Migration

  def change do
    create table(:obd_codes_obd_codes, primary_key: false) do
      add :code, :string, primary_key: true
      add :description, :string

      timestamps()
    end

  end
end
