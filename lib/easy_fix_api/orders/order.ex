defmodule EasyFixApi.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :state, EasyFixApi.Orders.StateEnum
    field :state_due_date, :utc_datetime
    # field :sub_state, :string
    # field :opening_date, :utc_datetime
    field :conclusion_date, :utc_datetime

    belongs_to :diagnosis, EasyFixApi.Orders.Diagnosis
    belongs_to :customer, EasyFixApi.Accounts.Customer

    timestamps(type: :utc_datetime)
  end

  @required_attrs ~w()a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end

  def update_state_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:state, :state_due_date])
    |> validate_required([:state])
  end

  @assoc_types %{diagnosis: :map, customer_id: :integer}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end

  def all_nested_assocs do
    [
      diagnosis: [EasyFixApi.Orders.Diagnosis.all_nested_assocs],
      customer: [EasyFixApi.Accounts.Customer.all_nested_assocs]
    ]
  end
end
