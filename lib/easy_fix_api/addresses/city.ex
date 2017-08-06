defmodule EasyFixApi.Addresses.City do
  use Ecto.Schema
  import Ecto.{Changeset}, warn: false

  schema "cities" do
    field :name, :string
    belongs_to :state, EasyFixApi.Addresses.State
    has_many :addresses, EasyFixApi.Addresses.Address

    timestamps(type: :utc_datetime)
  end

  def changeset(city, attrs) do
    city
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
