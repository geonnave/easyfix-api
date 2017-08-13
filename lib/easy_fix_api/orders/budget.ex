defmodule EasyFixApi.Orders.Budget do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "budgets" do
    field :due_date, :utc_datetime
    field :service_cost, :integer
    field :issuer_type, :string
    has_many :parts, EasyFixApi.Orders.BudgetPart
    belongs_to :diagnostic, EasyFixApi.Orders.Diagnostic
    belongs_to :issuer, EasyFixApi.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @optional_attrs ~w()
  @required_attrs ~w(due_date service_cost issuer_type)a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @optional_attrs ++ @required_attrs)
    |> validate_required(@required_attrs)
  end

  @assoc_types %{parts: {:array, :map}, diagnostic_id: :integer, issuer_id: :integer, issuer_type: :string}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end

  def all_nested_assocs do
    [parts: [:part], diagnostic: [], issuer: [:garage]]
  end
end
