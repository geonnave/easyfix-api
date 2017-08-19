defmodule EasyFixApi.Accounts.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "customers" do
    field :name, :string
    field :phone, :string
    field :cpf, :string
    field :accept_easyfix_policy, :utc_datetime
    belongs_to :user, EasyFixApi.Accounts.User
    belongs_to :bank_account, EasyFixApi.Payments.BankAccount
    belongs_to :address, EasyFixApi.Addresses.Address

    timestamps()
  end

  @required_fields ~w(name cpf phone accept_easyfix_policy)a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end

  @assoc_types %{address: :map, bank_account: :map}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end

  def all_nested_assocs do
    [user: [], bank_account: [:bank], address: [:city]]
  end
end
