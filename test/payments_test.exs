defmodule EasyFixApi.PaymentsTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Payments

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
