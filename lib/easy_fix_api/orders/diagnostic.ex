defmodule EasyFixApi.Orders.Diagnostic do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "diagnostics" do
    field :accepts_used_parts, :boolean, default: false
    field :comment, :string
    field :need_tow_truck, :boolean, default: false
    field :status, :string
    field :expiration_date, :utc_datetime
    has_many :diagnostics_parts, EasyFixApi.Orders.DiagnosticPart
    has_many :parts, through: [:diagnostics_parts, :part]
    has_many :budgets, EasyFixApi.Orders.Budget
    belongs_to :vehicle, EasyFixApi.Cars.Vehicle

    timestamps(type: :utc_datetime)
  end

  @optional_attrs ~w(comment)
  @required_attrs ~w(accepts_used_parts need_tow_truck status expiration_date)a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @optional_attrs ++ @required_attrs)
    |> validate_required(@required_attrs)
  end

  @assoc_types %{parts: {:array, :map}, vehicle_id: :integer}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end

  def all_nested_assocs do
    [
      parts: [:garage_category, [part_sub_group: [part_group: :part_system]], :repair_by_fixer_part],
      vehicle: [EasyFixApi.Cars.Vehicle.all_nested_assocs]
    ]
  end
end
