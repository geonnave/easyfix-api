defmodule EasyFixApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "users" do
    field :email, :string
    field :password_hash, :string

    # TODO make this field virtual: true
    field :password, :string

    has_many :addresses, EasyFixApi.Addresses.Address
    has_one :garage, EasyFixApi.Accounts.Garage
    # has_one :customer, EasyFixApi.Accounts.Customer

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:email])
    |> validate_required([:email])
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
