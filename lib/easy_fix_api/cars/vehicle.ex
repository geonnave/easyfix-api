defmodule EasyFixApi.Cars.Vehicle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vehicles" do
    field :model_year, :string
    field :production_year, :string
    field :plate, :string
    belongs_to :model, EasyFixApi.Cars.Model
    has_one :brand, through: [:model, :brand]

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(production_year model_year plate)a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(vehicle, attrs) do
    vehicle
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end

  @assoc_types %{model_id: :integer}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end

  def all_nested_assocs do
    []
  end
end
