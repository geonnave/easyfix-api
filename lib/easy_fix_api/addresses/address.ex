defmodule EasyFixApi.Addresses.Address do
  use Ecto.Schema
  import Ecto.{Changeset}, warn: false

  schema "addresses" do
    field :address_line1, :string
    field :address_line2, :string
    field :neighborhood, :string
    field :postal_code, :string
    belongs_to :city, EasyFixApi.Addresses.City
    belongs_to :user, EasyFixApi.Accounts.User

    timestamps()
  end

  @optional_attrs ~w()
  @required_attrs ~w(postal_code address_line1 address_line2 neighborhood)a

  def changeset(address, attrs) do
    address
    |> cast(attrs, @optional_attrs ++ @required_attrs)
    |> validate_required(@required_attrs)
  end

  @assoc_types %{city: :integer, user: :integer}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end
end