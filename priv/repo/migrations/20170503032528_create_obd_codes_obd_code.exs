defmodule EasyFixApi.Repo.Migrations.CreateEasyFixApi.OBDCodes.OBDCode do
  use Ecto.Migration

  def change do
    create table(:obd_codes_obd_codes) do
      add :code, :string
      add :description, :string

      timestamps()
    end

  end
end
