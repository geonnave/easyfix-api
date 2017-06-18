defmodule EasyFixApi.PartsTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Parts
  alias EasyFixApi.Parts.GarageCategory

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:garage_category, attrs \\ @create_attrs) do
    {:ok, garage_category} = Parts.create_garage_category(attrs)
    garage_category
  end

  test "list_garage_categories/1 returns all garage_categories" do
    garage_category = fixture(:garage_category)
    assert Parts.list_garage_categories() == [garage_category]
  end

  test "get_garage_category! returns the garage_category with given id" do
    garage_category = fixture(:garage_category)
    assert Parts.get_garage_category!(garage_category.id) == garage_category
  end

  test "create_garage_category/1 with valid data creates a garage_category" do
    assert {:ok, %GarageCategory{} = garage_category} = Parts.create_garage_category(@create_attrs)
    assert garage_category.name == "some name"
  end

  test "create_garage_category/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Parts.create_garage_category(@invalid_attrs)
  end

  test "update_garage_category/2 with valid data updates the garage_category" do
    garage_category = fixture(:garage_category)
    assert {:ok, garage_category} = Parts.update_garage_category(garage_category, @update_attrs)
    assert %GarageCategory{} = garage_category
    assert garage_category.name == "some updated name"
  end

  test "update_garage_category/2 with invalid data returns error changeset" do
    garage_category = fixture(:garage_category)
    assert {:error, %Ecto.Changeset{}} = Parts.update_garage_category(garage_category, @invalid_attrs)
    assert garage_category == Parts.get_garage_category!(garage_category.id)
  end

  test "delete_garage_category/1 deletes the garage_category" do
    garage_category = fixture(:garage_category)
    assert {:ok, %GarageCategory{}} = Parts.delete_garage_category(garage_category)
    assert_raise Ecto.NoResultsError, fn -> Parts.get_garage_category!(garage_category.id) end
  end

  test "change_garage_category/1 returns a garage_category changeset" do
    garage_category = fixture(:garage_category)
    assert %Ecto.Changeset{} = Parts.change_garage_category(garage_category)
  end
end
