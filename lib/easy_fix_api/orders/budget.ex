defmodule EasyFixApi.Orders.Budget do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "budgets" do
    field :service_cost, :integer
    field :status, :string
    field :sub_status, :string

    field :due_date, :utc_datetime
    field :conclusion_date, :utc_datetime

    field :total_amount, :integer, virtual: true

    field :issuer_type, EasyFixApi.Accounts.UserTypeEnum
    belongs_to :issuer, EasyFixApi.Accounts.User

    has_many :budgets_parts, EasyFixApi.Orders.BudgetPart, on_delete: :delete_all, on_replace: :nilify
    belongs_to :diagnosis, EasyFixApi.Orders.Diagnosis

    field :parts, {:array, :map}, virtual: true

    timestamps(type: :utc_datetime)
  end

  @optional_attrs ~w(due_date status sub_status)
  @required_attrs ~w(service_cost)a
  @assoc_attrs ~w(diagnosis_id issuer_id issuer_type parts)a

  def changeset(budget, attrs) do
    budget
    |> cast(attrs, @optional_attrs ++ @required_attrs ++ @assoc_attrs)
    |> validate_required(@required_attrs ++ @assoc_attrs)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def update_changeset(budget, attrs) do
    budget
    |> cast(attrs, [:parts] ++ @required_attrs)
  end

  def all_nested_assocs do
    [
      budgets_parts: [part: EasyFixApi.Parts.Part.all_nested_assocs],
      diagnosis: [],
      issuer: [:garage]
    ]
  end
end
