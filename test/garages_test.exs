defmodule EasyFixApi.GaragesTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Garages
  alias EasyFixApi.Garages.Garage

  @create_attrs %{cnpj: "some cnpj", email: "some email", name: "some name", owner_name: "some owner_name", password_hash: "some password_hash", phone: "some phone"}
  @update_attrs %{cnpj: "some updated cnpj", email: "some updated email", name: "some updated name", owner_name: "some updated owner_name", password_hash: "some updated password_hash", phone: "some updated phone"}
  @invalid_attrs %{cnpj: nil, email: nil, name: nil, owner_name: nil, password_hash: nil, phone: nil}

  def fixture(:garage, attrs \\ @create_attrs) do
    {:ok, garage} = Garages.create_garage(attrs)
    garage
  end

  test "list_garages/1 returns all garages" do
    garage = fixture(:garage)
    assert Garages.list_garages() == [garage]
  end

  test "get_garage! returns the garage with given id" do
    garage = fixture(:garage)
    assert Garages.get_garage!(garage.id) == garage
  end

  test "create_garage/1 with valid data creates a garage" do
    assert {:ok, %Garage{} = garage} = Garages.create_garage(@create_attrs)
    assert garage.cnpj == "some cnpj"
    assert garage.email == "some email"
    assert garage.name == "some name"
    assert garage.owner_name == "some owner_name"
    assert garage.password_hash == "some password_hash"
    assert garage.phone == "some phone"
  end

  test "create_garage/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Garages.create_garage(@invalid_attrs)
  end

  test "update_garage/2 with valid data updates the garage" do
    garage = fixture(:garage)
    assert {:ok, garage} = Garages.update_garage(garage, @update_attrs)
    assert %Garage{} = garage
    assert garage.cnpj == "some updated cnpj"
    assert garage.email == "some updated email"
    assert garage.name == "some updated name"
    assert garage.owner_name == "some updated owner_name"
    assert garage.password_hash == "some updated password_hash"
    assert garage.phone == "some updated phone"
  end

  test "update_garage/2 with invalid data returns error changeset" do
    garage = fixture(:garage)
    assert {:error, %Ecto.Changeset{}} = Garages.update_garage(garage, @invalid_attrs)
    assert garage == Garages.get_garage!(garage.id)
  end

  test "delete_garage/1 deletes the garage" do
    garage = fixture(:garage)
    assert {:ok, %Garage{}} = Garages.delete_garage(garage)
    assert_raise Ecto.NoResultsError, fn -> Garages.get_garage!(garage.id) end
  end

  test "change_garage/1 returns a garage changeset" do
    garage = fixture(:garage)
    assert %Ecto.Changeset{} = Garages.change_garage(garage)
  end
end
