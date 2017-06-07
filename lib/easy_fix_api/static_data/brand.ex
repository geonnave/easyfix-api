defmodule EasyFixApi.StaticData.Brand do
  use Ecto.Schema

  schema "static_data_brands" do
    field :name, :string

    timestamps()
  end
end
