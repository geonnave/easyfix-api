defmodule EasyFixApi.OBDCodes.OBDCode do
  use Ecto.Schema

  schema "obd_codes_obd_codes" do
    field :code, :string
    field :description, :string

    timestamps()
  end
end
