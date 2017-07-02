defmodule EasyFixApi.GaragesTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Garages
  alias EasyFixApi.Garages.Garage
  alias EasyFixApi.Parts.GarageCategory

  @create_attrs %{
    "cnpj" => "some cnpj",
    "email" => "some email",
    "name" => "some name",
    "owner_name" => "some owner_name",
    "password_hash" => "some password_hash",
    "phone" => "some phone"}
  @update_attrs %{
    "cnpj" => "some updated cnpj",
    "email" => "some updated email",
    "name" => "some updated name",
    "owner_name" => "some updated owner_name",
    "password_hash" => "some updated password_hash",
    "phone" => "some updated phone"}
  @invalid_attrs %{
    "cnpj" => nil,
    "email" => nil,
    "name" => nil,
    "owner_name" => nil,
    "password_hash" => nil,
    "phone" => nil,
    "garage_categories" => []}

  @catagory_a %GarageCategory{name: "foo"}
  @category_b %GarageCategory{name: "bar"}

  setup do
    %{id: category_a_id} = Repo.insert! @catagory_a
    %{id: category_b_id} = Repo.insert! @category_b
    [category_a_id: category_a_id, category_b_id: category_b_id]
  end

  def fixture(:garage, attrs \\ @create_attrs, cat_ids \\ []) do
    attrs = put_in attrs["garage_categories"], cat_ids
    {:ok, garage} = Garages.create_garage(attrs)
    garage
  end

  test "list_garages/1 returns all garages", %{category_a_id: category_a_id} do
    garage = fixture(:garage, @create_attrs, [category_a_id])
    assert Garages.list_garages() == [garage]
  end

  test "get_garage! returns the garage with given id", %{category_a_id: category_a_id} do
    garage = fixture(:garage, @create_attrs, [category_a_id])
    assert Garages.get_garage!(garage.id) == garage
  end

  test "get_garage! returns the correct associations", %{category_a_id: category_a_id} do
    garage = fixture(:garage, @create_attrs, [category_a_id])
    %{garage_categories: gc} = Garages.get_garage!(garage.id)
    assert Enum.map(gc, fn %{id: id} -> id end) == [category_a_id]
  end

  test "create_garage/1 with valid data creates a garage", %{category_a_id: category_a_id} do
    attrs = put_in @create_attrs["garage_categories"], [category_a_id]
    assert {:ok, %Garage{} = garage} = Garages.create_garage(attrs)
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

  test "update_garage/2 with valid data updates the garage", %{category_a_id: category_a_id, category_b_id: category_b_id} do
    garage = fixture(:garage, @create_attrs, [category_a_id])
    attrs = put_in @update_attrs["garage_categories"], [category_b_id]

    assert {:ok, garage} = Garages.update_garage(garage, attrs)
    assert %Garage{} = garage
    assert garage.cnpj == "some updated cnpj"
    assert garage.email == "some updated email"
    assert garage.name == "some updated name"
    assert garage.owner_name == "some updated owner_name"
    assert garage.password_hash == "some updated password_hash"
    assert garage.phone == "some updated phone"

    category_ids = Enum.map(garage.garage_categories, fn %{id: id} -> id end) |> Enum.sort
    category_a_and_b_ids = Enum.sort([category_a_id, category_b_id])
    assert category_a_and_b_ids == category_ids
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
