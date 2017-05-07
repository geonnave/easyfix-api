defmodule EasyFixApi.OBDCodes.OBDCode do
  use Ecto.Schema

  @primary_key {:code, :string, []}
  @derive {Phoenix.Param, key: :code}
  schema "obd_codes_obd_codes" do
    field :description, :string

    timestamps()
  end
end
