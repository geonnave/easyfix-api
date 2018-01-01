defmodule EasyFixApi.PaymentsTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Payments

  describe "banks" do
    @create_bank_attrs %{code: "some code", name: "some name"}
    @create_bank_account_attrs %{agency: "1111", number: "1234"}

    def fixture(:bank, attrs \\ @create_bank_attrs) do
      {:ok, bank} = Payments.create_bank(attrs)
      bank
    end

    test "list_banks/1 returns all banks" do
      bank = fixture(:bank)
      assert Payments.list_banks() == [bank]
    end

    test "get_bank! returns the bank with given id" do
      bank = fixture(:bank)
      assert Payments.get_bank!(bank.id) == bank
    end

    test "create_bank_account works" do
      bank = insert(:bank)

      {:ok, bank_account} =
        @create_bank_account_attrs
        |> put_in([:bank_id], bank.id)
        |> Payments.create_bank_account()

      assert bank_account.agency == "1111"
      assert bank_account.number == "1234"
      assert bank_account.bank.id == bank.id
    end
  end

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

  describe "payment_parts" do
    alias EasyFixApi.Payments.PaymentPart

    @valid_attrs %{price: 42, quantity: 42}
    @update_attrs %{price: 43, quantity: 43}
    @invalid_attrs %{price: nil, quantity: nil}

    def payment_part_fixture(attrs \\ %{}) do
      {:ok, payment_part} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_payment_part()

      payment_part
    end

    test "list_payment_parts/0 returns all payment_parts" do
      payment_part = payment_part_fixture()
      assert Payments.list_payment_parts() == [payment_part]
    end

    test "get_payment_part!/1 returns the payment_part with given id" do
      payment_part = payment_part_fixture()
      assert Payments.get_payment_part!(payment_part.id) == payment_part
    end

    test "create_payment_part/1 with valid data creates a payment_part" do
      payment = insert(:payment)
      part = insert(:part)
      payment_part_attrs =
        params_for(:payment_part)
        |> put_in([:payment_id], payment.id)
        |> put_in([:part_id], part.id)

      assert {:ok, %PaymentPart{} = payment_part} = Payments.create_payment_part(payment_part_attrs, payment.id)
      assert payment_part.price == payment_part_attrs.price
      assert payment_part.quantity == payment_part_attrs.quantity
    end

    test "create_payment_part/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_payment_part(@invalid_attrs)
    end

    test "update_payment_part/2 with valid data updates the payment_part" do
      payment_part = payment_part_fixture()
      assert {:ok, payment_part} = Payments.update_payment_part(payment_part, @update_attrs)
      assert %PaymentPart{} = payment_part
      assert payment_part.price == 43
      assert payment_part.quantity == 43
    end

    test "update_payment_part/2 with invalid data returns error changeset" do
      payment_part = payment_part_fixture()
      assert {:error, %Ecto.Changeset{}} = Payments.update_payment_part(payment_part, @invalid_attrs)
      assert payment_part == Payments.get_payment_part!(payment_part.id)
    end

    test "delete_payment_part/1 deletes the payment_part" do
      payment_part = payment_part_fixture()
      assert {:ok, %PaymentPart{}} = Payments.delete_payment_part(payment_part)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_payment_part!(payment_part.id) end
    end

    test "change_payment_part/1 returns a payment_part changeset" do
      payment_part = payment_part_fixture()
      assert %Ecto.Changeset{} = Payments.change_payment_part(payment_part)
    end
  end
end
