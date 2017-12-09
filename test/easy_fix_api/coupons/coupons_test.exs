defmodule EasyFixApi.CouponsTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Coupons

  describe "coupons" do
    alias EasyFixApi.Coupons.Coupon

    @valid_attrs %{code: "some code", description: "some description", discount: 42, discount_type: "some discount_type", expiration_date: "2010-04-17 14:00:00.000000Z", type: "some type"}
    @update_attrs %{code: "some updated code", description: "some updated description", discount: 43, discount_type: "some updated discount_type", expiration_date: "2011-05-18 15:01:01.000000Z", type: "some updated type"}
    @invalid_attrs %{code: nil, description: nil, discount: nil, discount_type: nil, expiration_date: nil, type: nil}

    def coupon_fixture(attrs \\ %{}) do
      {:ok, coupon} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Coupons.create_coupon()

      coupon
    end

    test "list_coupons/0 returns all coupons" do
      coupon = coupon_fixture()
      assert Coupons.list_coupons() == [coupon]
    end

    test "get_coupon!/1 returns the coupon with given id" do
      coupon = coupon_fixture()
      assert Coupons.get_coupon!(coupon.id) == coupon
    end

    test "create_coupon/1 with valid data creates a coupon" do
      assert {:ok, %Coupon{} = coupon} = Coupons.create_coupon(@valid_attrs)
      assert coupon.code == "some code"
      assert coupon.description == "some description"
      assert coupon.discount == 42
      assert coupon.discount_type == "some discount_type"
      assert coupon.expiration_date == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert coupon.type == "some type"
    end

    test "create_coupon/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Coupons.create_coupon(@invalid_attrs)
    end

    test "update_coupon/2 with valid data updates the coupon" do
      coupon = coupon_fixture()
      assert {:ok, coupon} = Coupons.update_coupon(coupon, @update_attrs)
      assert %Coupon{} = coupon
      assert coupon.code == "some updated code"
      assert coupon.description == "some updated description"
      assert coupon.discount == 43
      assert coupon.discount_type == "some updated discount_type"
      assert coupon.expiration_date == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert coupon.type == "some updated type"
    end

    test "update_coupon/2 with invalid data returns error changeset" do
      coupon = coupon_fixture()
      assert {:error, %Ecto.Changeset{}} = Coupons.update_coupon(coupon, @invalid_attrs)
      assert coupon == Coupons.get_coupon!(coupon.id)
    end

    test "delete_coupon/1 deletes the coupon" do
      coupon = coupon_fixture()
      assert {:ok, %Coupon{}} = Coupons.delete_coupon(coupon)
      assert_raise Ecto.NoResultsError, fn -> Coupons.get_coupon!(coupon.id) end
    end

    test "change_coupon/1 returns a coupon changeset" do
      coupon = coupon_fixture()
      assert %Ecto.Changeset{} = Coupons.change_coupon(coupon)
    end
  end

  describe "customers_coupons" do
    alias EasyFixApi.Coupons.CustomerCoupon

    @valid_attrs %{expiration_date: "2010-04-17 14:00:00.000000Z", quantity: 42}
    @update_attrs %{expiration_date: "2011-05-18 15:01:01.000000Z", quantity: 43}
    @invalid_attrs %{expiration_date: nil, quantity: nil}

    def customer_coupon_fixture(attrs \\ %{}) do
      {:ok, customer_coupon} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Coupons.create_customer_coupon()

      customer_coupon
    end

    test "list_customers_coupons/0 returns all customers_coupons" do
      customer_coupon = customer_coupon_fixture()
      assert Coupons.list_customers_coupons() == [customer_coupon]
    end

    test "get_customer_coupon!/1 returns the customer_coupon with given id" do
      customer_coupon = customer_coupon_fixture()
      assert Coupons.get_customer_coupon!(customer_coupon.id) == customer_coupon
    end

    test "create_customer_coupon/1 with valid data creates a customer_coupon" do
      assert {:ok, %CustomerCoupon{} = customer_coupon} = Coupons.create_customer_coupon(@valid_attrs)
      assert customer_coupon.expiration_date == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert customer_coupon.quantity == 42
    end

    test "create_customer_coupon/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Coupons.create_customer_coupon(@invalid_attrs)
    end

    test "update_customer_coupon/2 with valid data updates the customer_coupon" do
      customer_coupon = customer_coupon_fixture()
      assert {:ok, customer_coupon} = Coupons.update_customer_coupon(customer_coupon, @update_attrs)
      assert %CustomerCoupon{} = customer_coupon
      assert customer_coupon.expiration_date == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert customer_coupon.quantity == 43
    end

    test "update_customer_coupon/2 with invalid data returns error changeset" do
      customer_coupon = customer_coupon_fixture()
      assert {:error, %Ecto.Changeset{}} = Coupons.update_customer_coupon(customer_coupon, @invalid_attrs)
      assert customer_coupon == Coupons.get_customer_coupon!(customer_coupon.id)
    end

    test "delete_customer_coupon/1 deletes the customer_coupon" do
      customer_coupon = customer_coupon_fixture()
      assert {:ok, %CustomerCoupon{}} = Coupons.delete_customer_coupon(customer_coupon)
      assert_raise Ecto.NoResultsError, fn -> Coupons.get_customer_coupon!(customer_coupon.id) end
    end

    test "change_customer_coupon/1 returns a customer_coupon changeset" do
      customer_coupon = customer_coupon_fixture()
      assert %Ecto.Changeset{} = Coupons.change_customer_coupon(customer_coupon)
    end
  end
end
