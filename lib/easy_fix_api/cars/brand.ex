defmodule EasyFixApi.Cars.Brand do
  use Ecto.Schema

  schema "brands" do
    field :name, :string
    has_many :models, EasyFixApi.Cars.Model

    timestamps()
  end
end
