defmodule EasyFixApi.Parts.GarageCategory do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "garage_categories" do
    field :name, :string
    has_many :parts, EasyFixApi.Parts.Part
    many_to_many :garages, EasyFixApi.Parts.GarageCategory, join_through: "garages_garage_categories"

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
