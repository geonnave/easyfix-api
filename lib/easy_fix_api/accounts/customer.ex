defmodule EasyFixApi.Accounts.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "customers" do
    field :name, :string
    field :phone, :string
    field :cpf, :string
    field :accept_easyfix_policy, :utc_datetime
    field :indication_code, :string

    belongs_to :user, EasyFixApi.Accounts.User
    belongs_to :address, EasyFixApi.Addresses.Address
    many_to_many :vehicles, EasyFixApi.Cars.Vehicle,
      join_through: "vehicles_customers",
      on_delete: :delete_all
    has_many :orders, EasyFixApi.Orders.Order
    has_many :indication_codes, EasyFixApi.Vouchers.IndicationCode

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(name cpf phone accept_easyfix_policy)a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def create_basic_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_fields)
    |> validate_required([:name, :phone, :accept_easyfix_policy])
  end

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end

  def update_changeset(customer, attrs) do
    customer
    |> cast(attrs, [:indication_code])
    |> validate_required([:indication_code])
  end

  @assoc_types %{address: :map, vehicles: {:array, :map}}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end

  def all_nested_assocs do
    [user: [], address: [:city], vehicles: [:model, :brand]]
  end
end
