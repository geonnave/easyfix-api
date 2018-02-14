defmodule EasyFixApi.VouchersTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Vouchers

  describe "indication_codes" do
    alias EasyFixApi.Vouchers.IndicationCode

    @valid_attrs %{code: "some code", date_used: "2010-04-17 14:00:00.000000Z", type: "some type"}
    @update_attrs %{code: "some updated code", date_used: "2011-05-18 15:01:01.000000Z", type: "some updated type"}
    @invalid_attrs %{code: nil, date_used: nil, type: nil}

    def indication_code_fixture(attrs \\ %{}) do
      {:ok, indication_code} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Vouchers.create_indication_code()

      indication_code
    end

    test "list_indication_codes/0 returns all indication_codes" do
      indication_code = indication_code_fixture()
      assert Vouchers.list_indication_codes() == [indication_code]
    end

    test "get_indication_code!/1 returns the indication_code with given id" do
      indication_code = indication_code_fixture()
      assert Vouchers.get_indication_code!(indication_code.id) == indication_code
    end

    test "create_indication_code/1 with valid data creates a indication_code" do
      assert {:ok, %IndicationCode{} = indication_code} = Vouchers.create_indication_code(@valid_attrs)
      assert indication_code.code == "some code"
      assert indication_code.date_used == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert indication_code.type == "some type"
    end

    test "create_indication_code/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Vouchers.create_indication_code(@invalid_attrs)
    end

    test "update_indication_code/2 with valid data updates the indication_code" do
      indication_code = indication_code_fixture()
      assert {:ok, indication_code} = Vouchers.update_indication_code(indication_code, @update_attrs)
      assert %IndicationCode{} = indication_code
      assert indication_code.code == "some updated code"
      assert indication_code.date_used == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert indication_code.type == "some updated type"
    end

    test "update_indication_code/2 with invalid data returns error changeset" do
      indication_code = indication_code_fixture()
      assert {:error, %Ecto.Changeset{}} = Vouchers.update_indication_code(indication_code, @invalid_attrs)
      assert indication_code == Vouchers.get_indication_code!(indication_code.id)
    end

    test "delete_indication_code/1 deletes the indication_code" do
      indication_code = indication_code_fixture()
      assert {:ok, %IndicationCode{}} = Vouchers.delete_indication_code(indication_code)
      assert_raise Ecto.NoResultsError, fn -> Vouchers.get_indication_code!(indication_code.id) end
    end

    test "change_indication_code/1 returns a indication_code changeset" do
      indication_code = indication_code_fixture()
      assert %Ecto.Changeset{} = Vouchers.change_indication_code(indication_code)
    end
  end
end
