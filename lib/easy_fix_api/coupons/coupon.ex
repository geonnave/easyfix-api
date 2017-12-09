defmodule EasyFixApi.Coupons.Coupon do
  use Ecto.Schema
  import Ecto.Changeset
  alias EasyFixApi.Coupons.Coupon

  schema "coupons" do
    field :code, :string
    field :description, :string
    field :discount, :integer
    field :discount_type, :string
    field :expiration_date, :utc_datetime
    field :type, :string

    belongs_to :owner, EasyFixApi.Accounts.Customer

    timestamps()
  end

  @doc false
  def changeset(%Coupon{} = coupon, attrs) do
    coupon
    |> cast(attrs, [:code, :type, :discount, :discount_type, :description, :expiration_date])
    |> validate_required([:code, :type, :discount, :discount_type, :description, :expiration_date])
  end
end
