defmodule EasyFixApi.Orders.BudgetPart do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "budgets_parts" do
    belongs_to :budget, EasyFixApi.Orders.Budget
    belongs_to :part, EasyFixApi.Parts.Part
    field :quantity, :integer
    field :price, :integer

    timestamps(type: :utc_datetime)
  end

  @optional_attrs ~w()
  @required_attrs ~w(quantity price)a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @optional_attrs ++ @required_attrs)
    |> validate_required(@required_attrs)
  end

  @assoc_types %{part_id: :integer}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end
end
