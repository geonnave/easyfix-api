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

    has_many :budgets_parts, EasyFixApi.Orders.BudgetPart
    has_many :parts, through: [:budgets_parts, :part]
    belongs_to :diagnosis, EasyFixApi.Orders.Diagnosis

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

  @assoc_types %{parts: {:array, :map}, diagnosis_id: :integer, issuer_id: :integer, issuer_type: :string}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end

  def all_nested_assocs do
    [
      parts: [:garage_category, [part_sub_group: [part_group: :part_system]], :repair_by_fixer_part],
      diagnosis: [],
      issuer: [:garage]
    ]
  end
end
