defmodule EasyFixApi.Coupons do
  @moduledoc """
  The Coupons context.
  """

  import Ecto.Query, warn: false
  alias EasyFixApi.Repo

  alias EasyFixApi.Coupons.Coupon

  def list_coupons do
    Repo.all(Coupon)
  end

  def get_coupon!(id), do: Repo.get!(Coupon, id)

  def create_coupon(attrs \\ %{}) do
    %Coupon{}
    |> Coupon.changeset(attrs)
    |> Repo.insert()
  end

  def update_coupon(%Coupon{} = coupon, attrs) do
    coupon
    |> Coupon.changeset(attrs)
    |> Repo.update()
  end

  def delete_coupon(%Coupon{} = coupon) do
    Repo.delete(coupon)
  end

  def change_coupon(%Coupon{} = coupon) do
    Coupon.changeset(coupon, %{})
  end

  alias EasyFixApi.Coupons.CustomerCoupon

  def list_customers_coupons do
    Repo.all(CustomerCoupon)
  end

  def get_customer_coupon!(id), do: Repo.get!(CustomerCoupon, id)

  def create_customer_coupon(attrs \\ %{}) do
    %CustomerCoupon{}
    |> CustomerCoupon.changeset(attrs)
    |> Repo.insert()
  end

  def update_customer_coupon(%CustomerCoupon{} = customer_coupon, attrs) do
    customer_coupon
    |> CustomerCoupon.changeset(attrs)
    |> Repo.update()
  end

  def delete_customer_coupon(%CustomerCoupon{} = customer_coupon) do
    Repo.delete(customer_coupon)
  end

  def change_customer_coupon(%CustomerCoupon{} = customer_coupon) do
    CustomerCoupon.changeset(customer_coupon, %{})
  end
end
