defmodule EasyFixApi.Coupons.CustomerCoupon do
  use Ecto.Schema
  import Ecto.Changeset
  alias EasyFixApi.Coupons.CustomerCoupon

  schema "customers_coupons" do
    field :expiration_date, :utc_datetime
    field :quantity, :integer

    belongs_to :customer, EasyFixApi.Accounts.Customer
    belongs_to :coupon, EasyFixApi.Coupons.Coupon

    timestamps()
  end

  @doc false
  def changeset(%CustomerCoupon{} = customer_coupon, attrs) do
    customer_coupon
    |> cast(attrs, [:quantity, :expiration_date])
    |> validate_required([:quantity, :expiration_date])
  end
end
