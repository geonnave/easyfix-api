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
        |> Enum.into(params_for(:payment))
        |> Payments.create_payment()

      payment
    end

    test "get_payment!/1 returns the payment with given id" do
      payment = insert(:payment)
      assert Payments.get_payment!(payment.id).id == payment.id
    end

    test "create_payment/1 with valid data creates a payment" do
      quote = insert(:quote)
      parts = [
        %{part_id: insert(:part).id, quantity: 1, price: 4200},
      ]

      payment_attrs =
        params_for(:payment)
        |> put_in([:quote_id], quote.id)
        |> put_in([:parts], parts)
        |> IO.inspect

      assert {:ok, %Payment{} = payment} = Payments.create_payment(payment_attrs)
      assert payment.amount == 42
      assert payment.state == "some state"
    end

    test "create_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_payment(@invalid_attrs)
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
        |> put_in([:payment_id], payment.id)
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
