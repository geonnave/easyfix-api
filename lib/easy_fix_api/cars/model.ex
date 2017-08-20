defmodule EasyFixApi.Cars.Model do
  use Ecto.Schema

  schema "models" do
    field :name, :string
    belongs_to :brand, EasyFixApi.Cars.Brand
    has_many :vehicles, EasyFixApi.Cars.Vehicle

    timestamps(type: :utc_datetime)
  end
end
