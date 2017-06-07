defmodule EasyFixApi.StaticData.Model do
  use Ecto.Schema

  schema "static_data_models" do
    field :name, :string
    field :brand_id, :id

    timestamps()
  end
end
