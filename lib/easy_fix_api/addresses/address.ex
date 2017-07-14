defmodule EasyFixApi.Addresses.Address do
  use Ecto.Schema
  import Ecto.{Changeset}, warn: false

  schema "addresses" do
    field :address_line1, :string
    field :address_line2, :string
    field :neighborhood, :string
    field :postal_code, :string
    belongs_to :city, EasyFixApi.Addresses.City

    timestamps()
  end

  def changeset(address, attrs) do
    address
    |> cast(attrs, [:postal_code, :address_line1, :address_line2, :neighborhood])
    |> validate_required([:postal_code, :address_line1, :address_line2, :neighborhood])
  end
end
