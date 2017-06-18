defmodule EasyFixApi.Parts.GarageCategory do
  use Ecto.Schema

  schema "garage_categories" do
    field :name, :string
    has_many :parts, EasyFixApi.Parts.Part

    timestamps()
  end
end
