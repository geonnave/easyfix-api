defmodule EasyFixApi.PaymentsTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Payments

  describe "payments" do
    alias EasyFixApi.Payments.Payment

    @valid_attrs %{amount: 42, factoring_fee: "120.5", installments: 42, iugu_fee: "120.5", iugu_invoice_id: "some iugu_invoice_id", payment_method: "some payment_method", state: "some state"}
    @update_attrs %{amount: 43, factoring_fee: "456.7", installments: 43, iugu_fee: "456.7", iugu_invoice_id: "some updated iugu_invoice_id", payment_method: "some updated payment_method", state: "some updated state"}
    @invalid_attrs %{amount: nil, factoring_fee: nil, installments: nil, iugu_fee: nil, iugu_invoice_id: nil, payment_method: nil, state: nil}

    def payment_fixture(attrs \\ %{}) do
      {:ok, payment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_payment()

      payment
    end

    test "list_payments/0 returns all payments" do
      payment = payment_fixture()
      assert Payments.list_payments() == [payment]
    end

    test "get_payment!/1 returns the payment with given id" do
      payment = payment_fixture()
      assert Payments.get_payment!(payment.id) == payment
    end

    test "create_payment/1 with valid data creates a payment" do
      assert {:ok, %Payment{} = payment} = Payments.create_payment(@valid_attrs)
      assert payment.amount == 42
      assert payment.factoring_fee == Decimal.new("120.5")
      assert payment.installments == 42
      assert payment.iugu_fee == Decimal.new("120.5")
      assert payment.iugu_invoice_id == "some iugu_invoice_id"
      assert payment.payment_method == "some payment_method"
      assert payment.state == "some state"
    end

    test "create_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_payment(@invalid_attrs)
    end

    test "update_payment/2 with valid data updates the payment" do
      payment = payment_fixture()
      assert {:ok, payment} = Payments.update_payment(payment, @update_attrs)
      assert %Payment{} = payment
      assert payment.amount == 43
      assert payment.factoring_fee == Decimal.new("456.7")
      assert payment.installments == 43
      assert payment.iugu_fee == Decimal.new("456.7")
      assert payment.iugu_invoice_id == "some updated iugu_invoice_id"
      assert payment.payment_method == "some updated payment_method"
      assert payment.state == "some updated state"
    end

    test "update_payment/2 with invalid data returns error changeset" do
      payment = payment_fixture()
      assert {:error, %Ecto.Changeset{}} = Payments.update_payment(payment, @invalid_attrs)
      assert payment == Payments.get_payment!(payment.id)
    end

    test "delete_payment/1 deletes the payment" do
      payment = payment_fixture()
      assert {:ok, %Payment{}} = Payments.delete_payment(payment)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_payment!(payment.id) end
    end

    test "change_payment/1 returns a payment changeset" do
      payment = payment_fixture()
      assert %Ecto.Changeset{} = Payments.change_payment(payment)
    end
  end
end
