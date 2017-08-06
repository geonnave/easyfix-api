defmodule EasyFixApi.Cars.Model do
  use Ecto.Schema

  schema "models" do
    field :name, :string
    belongs_to :brand, EasyFixApi.Cars.Brand

    timestamps(type: :utc_datetime)
  end
end
