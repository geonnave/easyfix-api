defmodule EasyFixApi.Orders.Budget do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "budgets" do
    field :due_date, :utc_datetime
    field :service_cost, :integer

    timestamps(type: :utc_datetime)
  end

  @optional_attrs ~w()
  @required_attrs ~w(due_date service_cost)a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @optional_attrs ++ @required_attrs)
    |> validate_required(@required_attrs)
  end

  @assoc_types %{}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end
end
