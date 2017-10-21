defmodule EasyFixApi.Orders.Diagnosis do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "diagnosis" do
    field :accepts_used_parts, :boolean, default: false
    field :comment, :string
    field :need_tow_truck, :boolean, default: false
    field :status, :string
    field :expiration_date, :utc_datetime
    field :vehicle_mileage, :integer

    has_many :quotes, EasyFixApi.Orders.Quote, on_delete: :delete_all
    belongs_to :order, EasyFixApi.Orders.Order

    has_many :diagnosis_parts, EasyFixApi.Orders.DiagnosisPart
    has_many :parts, through: [:diagnosis_parts, :part]

    belongs_to :vehicle, EasyFixApi.Cars.Vehicle

    timestamps(type: :utc_datetime)
  end

  @optional_attrs ~w(comment status expiration_date vehicle_mileage)
  @required_attrs ~w(accepts_used_parts need_tow_truck)a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @optional_attrs ++ @required_attrs)
    |> validate_required(@required_attrs)
  end

  def update_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:expiration_date])
    |> validate_required([:expiration_date])
  end

  @assoc_types %{parts: {:array, :map}, vehicle_id: :integer}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end

  def all_nested_assocs do
    [
      parts: [:garage_category, [part_sub_group: [part_group: :part_system]]],
      vehicle: [EasyFixApi.Cars.Vehicle.all_nested_assocs]
    ]
  end
end
