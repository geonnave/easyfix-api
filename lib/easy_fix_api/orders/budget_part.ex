defmodule EasyFixApi.Orders.BudgetPart do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "budgets_parts" do
    belongs_to :budget, EasyFixApi.Orders.Budget
    belongs_to :part, EasyFixApi.Parts.Part, on_replace: :nilify
    field :quantity, :integer
    field :price, Money.Ecto.Type

    timestamps(type: :utc_datetime)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:quantity, :price, :part_id])
    |> validate_required([:quantity, :price, :part_id])
  end

  def update_changeset(budget_part, attrs) do
    budget_part
    |> cast(attrs, [:quantity, :price, :part_id])
  end
end
