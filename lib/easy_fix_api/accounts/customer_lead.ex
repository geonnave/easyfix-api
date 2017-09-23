defmodule EasyFixApi.Accounts.CustomerLead do
  use Ecto.Schema
  import Ecto.Changeset

  schema "customer_leads" do
    field :name, :string
    field :phone, :string
    field :email, :string

    embeds_one :car, Car do
      field :model, :string
      field :brand, :string
      field :year, :integer
    end
    embeds_one :address, Address do
      field :city
      field :neighborhood, :string
    end

    belongs_to :garage, EasyFixApi.Accounts.Garage

    timestamps(type: :utc_datetime)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(customer_lead, attrs) do
    customer_lead
    |> cast(attrs, [:name, :phone, :email, :garage_id])
    |> cast_assoc(:garage)
    |> validate_required([:name, :email, :phone])
    |> cast_embed(:car, with: &car_changeset/2)
    |> cast_embed(:address, with: &address_changeset/2)
  end

  def car_changeset(car, attrs) do
    car
    |> cast(attrs, [:model, :brand, :year])
    |> validate_required([:model, :brand, :year])
  end

  def address_changeset(address, attrs) do
    address
    |> cast(attrs, [:city, :neighborhood])
    |> validate_required([:city, :neighborhood])
  end
end
