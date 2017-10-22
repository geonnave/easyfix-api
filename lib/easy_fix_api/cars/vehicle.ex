defmodule EasyFixApi.Cars.Vehicle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vehicles" do
    field :model_year, :string
    field :production_year, :string
    field :plate, :string
    field :vehicle_id_number, :string # chassis
    field :mileage, :integer
    belongs_to :model, EasyFixApi.Cars.Model
    has_one :brand, through: [:model, :brand]

    timestamps(type: :utc_datetime)
  end

  @optional_fields ~w(vehicle_id_number mileage plate production_year)a
  @required_fields ~w(model_year)a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(vehicle, attrs) do
    vehicle
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  @assoc_types %{model_id: :integer}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end

  def all_nested_assocs do
    [:model, :brand]
  end
end
