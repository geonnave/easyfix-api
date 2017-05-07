defmodule EasyFixApi.OBDCodesTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.OBDCodes
  alias EasyFixApi.OBDCodes.OBDCode

  @create_attrs %{code: "some code", description: "some description"}
  @update_attrs %{code: "some updated code", description: "some updated description"}
  @invalid_attrs %{code: nil, description: nil}

  def fixture(:obd_code, attrs \\ @create_attrs) do
    {:ok, obd_code} = OBDCodes.create_obd_code(attrs)
    obd_code
  end

  test "list_obd_codes/1 returns all obd_codes" do
    obd_code = fixture(:obd_code)
    assert OBDCodes.list_obd_codes() == [obd_code]
  end

  test "get_obd_code! returns the obd_code with given id" do
    obd_code = fixture(:obd_code)
    assert OBDCodes.get_obd_code!(obd_code.code) == obd_code
  end

  test "create_obd_code/1 with valid data creates a obd_code" do
    assert {:ok, %OBDCode{} = obd_code} = OBDCodes.create_obd_code(@create_attrs)
    assert obd_code.code == "some code"
    assert obd_code.description == "some description"
  end

  test "create_obd_code/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = OBDCodes.create_obd_code(@invalid_attrs)
  end

  test "update_obd_code/2 with valid data updates the obd_code" do
    obd_code = fixture(:obd_code)
    assert {:ok, obd_code} = OBDCodes.update_obd_code(obd_code, @update_attrs)
    assert %OBDCode{} = obd_code
    assert obd_code.code == "some updated code"
    assert obd_code.description == "some updated description"
  end

  test "update_obd_code/2 with invalid data returns error changeset" do
    obd_code = fixture(:obd_code)
    assert {:error, %Ecto.Changeset{}} = OBDCodes.update_obd_code(obd_code, @invalid_attrs)
    assert obd_code == OBDCodes.get_obd_code!(obd_code.code)
  end

  test "delete_obd_code/1 deletes the obd_code" do
    obd_code = fixture(:obd_code)
    assert {:ok, %OBDCode{}} = OBDCodes.delete_obd_code(obd_code)
    assert_raise Ecto.NoResultsError, fn -> OBDCodes.get_obd_code!(obd_code.code) end
  end

  test "change_obd_code/1 returns a obd_code changeset" do
    obd_code = fixture(:obd_code)
    assert %Ecto.Changeset{} = OBDCodes.change_obd_code(obd_code)
  end
end
