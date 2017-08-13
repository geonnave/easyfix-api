defmodule EasyFixApi.Orders.Budget do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "budgets" do
    field :service_cost, :integer
    field :status, :string
    field :sub_status, :string

    field :opening_date, :utc_datetime
    field :due_date, :utc_datetime
    field :conclusion_date, :utc_datetime

    field :issuer_type, EasyFixApi.Accounts.UserTypeEnum
    belongs_to :issuer, EasyFixApi.Accounts.User

    has_many :parts, EasyFixApi.Orders.BudgetPart
    belongs_to :diagnostic, EasyFixApi.Orders.Diagnostic

    timestamps(type: :utc_datetime)
  end

  @optional_attrs ~w()
  @required_attrs ~w(service_cost status sub_status opening_date due_date issuer_type)a

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
