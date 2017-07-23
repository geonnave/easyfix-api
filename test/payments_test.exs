defmodule EasyFixApi.PaymentsTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Payments

  @create_attrs %{code: "some code", name: "some name"}

  def fixture(:bank, attrs \\ @create_attrs) do
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
end
