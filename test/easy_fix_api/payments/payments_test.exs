defmodule EasyFixApi.PaymentsTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Payments

  describe "payments" do
    alias EasyFixApi.Payments.Payment

    @invalid_attrs %{total_amount: nil, factoring_fee: nil, installments: nil, iugu_fee: nil, iugu_invoice_id: nil, payment_method: nil, state: nil}

    test "get_payment!/1 returns the payment with given id" do
      payment = insert(:payment)
      assert Payments.get_payment!(payment.id).id == payment.id
    end

    test "create pending changeset" do
      assert %{valid?: true} = %{
        "token" => "xablau",
        "total_amount" => 20_00,
        "installments" => 1,
        "payment_method" => "credit",
        "iugu_fee" => 3.21,
        "factoring_fee" => 2.9,
        "quote_id" => 1,
        "order_id" => 1,
      }
      |> Payment.pending_changeset
    end

    @tag :skip
    test "create_payment/1 with valid data creates a payment" do
      quote = insert(:quote)
      customer = insert(:customer)

      payment_attrs =
        params_for(:payment)
        |> put_in([:quote_id], quote.id)
        |> IO.inspect

      assert {:ok, %Payment{} = payment} = Payments.create_payment(payment_attrs, customer.id)
      assert payment.total_amount == 42
      assert payment.state == "some state"
    end

    test "create_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_payment(@invalid_attrs)
    end
  end

  describe "iugu" do
    alias EasyFixApi.Payments.Payment

    test "build iugu payload" do
    end
  end

  describe "payment_parts" do
    alias EasyFixApi.Payments.PaymentPart

    @invalid_attrs %{price: nil, quantity: nil}

    def payment_part_fixture(attrs \\ %{}) do
      payment = insert(:payment)
      part = insert(:part)
      payment_part_attrs =
        attrs
        |> Enum.into(params_for(:payment_part))
        |> put_in([:payment_id], payment.id)
        |> put_in([:part_id], part.id)

      {:ok, payment_part} = Payments.create_payment_part(payment_part_attrs, payment.id)

      payment_part
    end

    test "create_payment_part/1 with valid data creates a payment_part" do
      payment = insert(:payment)
      part = insert(:part)
      payment_part_attrs =
        params_for(:payment_part)
        |> put_in([:part_id], part.id)

      assert {:ok, %PaymentPart{} = payment_part} = Payments.create_payment_part(payment_part_attrs, payment.id)
      assert payment_part.price == payment_part_attrs.price
      assert payment_part.quantity == payment_part_attrs.quantity
    end

    test "create_payment_part/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_payment_part(@invalid_attrs)
    end
  end
end
