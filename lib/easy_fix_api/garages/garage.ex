defmodule EasyFixApi.Garages.Garage do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "garages" do
    field :cnpj, :string
    field :email, :string
    field :name, :string
    field :owner_name, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :phone, :string
    many_to_many :garage_categories, EasyFixApi.Parts.GarageCategory, join_through: "garages_garage_categories"

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name, :owner_name, :email, :phone, :cnpj])
    |> validate_required([:name, :owner_name, :email, :phone, :cnpj])
    |> validate_length(:email, min: 1, max: 255)
    |> validate_format(:email, ~r/@/)
  end

  def registration_changeset(struct, attrs) do
    struct
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> put_password_hash()
  end

  def put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
