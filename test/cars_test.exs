defmodule EasyFixApi.CarsTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Cars
  alias EasyFixApi.Cars.Brand

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:brand, attrs \\ @create_attrs) do
    {:ok, brand} = Cars.create_brand(attrs)
    brand
  end

  test "list_brands/1 returns all brands" do
    brand = fixture(:brand)
    assert Cars.list_brands() == [brand]
  end

  test "get_brand! returns the brand with given id" do
    brand = fixture(:brand)
    assert Cars.get_brand!(brand.id) == brand
  end

  test "create_brand/1 with valid data creates a brand" do
    assert {:ok, %Brand{} = brand} = Cars.create_brand(@create_attrs)
    assert brand.name == "some name"
  end

  test "create_brand/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Cars.create_brand(@invalid_attrs)
  end

  test "update_brand/2 with valid data updates the brand" do
    brand = fixture(:brand)
    assert {:ok, brand} = Cars.update_brand(brand, @update_attrs)
    assert %Brand{} = brand
    assert brand.name == "some updated name"
  end

  test "update_brand/2 with invalid data returns error changeset" do
    brand = fixture(:brand)
    assert {:error, %Ecto.Changeset{}} = Cars.update_brand(brand, @invalid_attrs)
    assert brand == Cars.get_brand!(brand.id)
  end

  test "delete_brand/1 deletes the brand" do
    brand = fixture(:brand)
    assert {:ok, %Brand{}} = Cars.delete_brand(brand)
    assert_raise Ecto.NoResultsError, fn -> Cars.get_brand!(brand.id) end
  end

  test "change_brand/1 returns a brand changeset" do
    brand = fixture(:brand)
    assert %Ecto.Changeset{} = Cars.change_brand(brand)
  end
end
