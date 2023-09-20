defmodule EasyFixApi.Addresses.Address do
  use Ecto.Schema
  import Ecto.{Changeset}, warn: false

  schema "addresses" do
    field :address_line1, :string
    field :address_line2, :string
    field :neighborhood, :string
    field :postal_code, :string
    belongs_to :city, EasyFixApi.Addresses.City

    timestamps(type: :utc_datetime)
  end

  @optional_attrs ~w(address_line2)
  @required_attrs ~w(postal_code address_line1 neighborhood)a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def create_basic_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @optional_attrs ++ @required_attrs)
  end

  def changeset(address, attrs) do
    address
    |> cast(attrs, @optional_attrs ++ @required_attrs)
    |> validate_required(@required_attrs)
  end

  def update_changeset(address, attrs) do
    address
    |> cast(attrs, @optional_attrs ++ @required_attrs)
    |> validate_required(@required_attrs)
  end

  @assoc_types %{city_id: :integer}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end

  def all_nested_assocs do
    [city: [:state]]
  end
end
