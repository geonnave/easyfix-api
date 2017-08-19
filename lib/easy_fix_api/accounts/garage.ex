defmodule EasyFixApi.Accounts.Garage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "garages" do
    field :cnpj, :string
    field :name, :string
    field :owner_name, :string
    field :phone, :string
    many_to_many :garage_categories,
      EasyFixApi.Parts.GarageCategory,
      join_through: "garages_garage_categories",
      on_delete: :delete_all
    belongs_to :user, EasyFixApi.Accounts.User
    belongs_to :bank_account, EasyFixApi.Payments.BankAccount
    belongs_to :address, EasyFixApi.Addresses.Address

    timestamps(type: :utc_datetime)
  end

  @optional_attrs ~w()
  @required_attrs ~w(name owner_name phone cnpj)a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @optional_attrs ++ @required_attrs)
    |> validate_required(@required_attrs)
  end

  @assoc_types %{garage_categories_ids: {:array, :integer}, address: :map, bank_account: :map}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end

  def all_nested_assocs do
    [user: [], bank_account: [:bank], garage_categories: [], address: []]
  end
end
