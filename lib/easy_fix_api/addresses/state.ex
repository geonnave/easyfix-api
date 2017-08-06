defmodule EasyFixApi.Addresses.State do
  use Ecto.Schema
  import Ecto.{Changeset}, warn: false

  schema "states" do
    field :name, :string
    has_many :cities, EasyFixApi.Addresses.City

    timestamps(type: :utc_datetime)
  end

  def changeset(state, attrs) do
    state
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
