defmodule EasyFixApi.Accounts.Garage do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "garages" do
    field :cnpj, :string
    field :name, :string
    field :owner_name, :string
    field :phone, :string
    many_to_many :garage_categories, EasyFixApi.Parts.GarageCategory, join_through: "garages_garage_categories"
    belongs_to :user, EasyFixApi.Accounts.User
    belongs_to :bank_account, EasyFixApi.Payments.BankAccount

    timestamps()
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name, :owner_name, :phone, :cnpj])
    |> validate_required([:name, :owner_name, :phone, :cnpj])
  end

  @assoc_types %{garage_categories_ids: {:array, :integer}, address: :map, bank_account: :map}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end
end
