defmodule EasyFixApi.GaragesTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Accounts
  alias EasyFixApi.Accounts.Garage
  alias EasyFixApi.Parts.GarageCategory

  @create_attrs %{
    cnpj: "some cnpj",
    email: "some@email.com",
    name: "some name",
    owner_name: "some owner_name",
    password: "some password",
    phone: "some phone"}
  @update_attrs %{
    cnpj: "some updated cnpj",
    email: "some@updated_email.com",
    name: "some updated name",
    owner_name: "some updated owner_name",
    password: "some updated password",
    phone: "some updated phone"}
  @invalid_attrs %{
    cnpj: nil,
    email: "some@email.com",
    name: nil,
    owner_name: nil,
    password: "some password",
    phone: nil,
    garage_categories: []}

  @catagory_a %GarageCategory{name: "foo"}
  @category_b %GarageCategory{name: "bar"}

  setup do
    %{id: category_a_id} = Repo.insert! @catagory_a
    %{id: category_b_id} = Repo.insert! @category_b
    [category_a_id: category_a_id, category_b_id: category_b_id]
  end

  def fixture(:garage, attrs \\ @create_attrs, cat_ids \\ []) do
    attrs = put_in attrs[:garage_categories], cat_ids
    {:ok, garage} = Accounts.create_garage(%{garage: attrs, garage_categories: cat_ids})
    %{garage | user: %{garage.user | password: nil}}
  end

  test "list_garages/1 returns all garages", %{category_a_id: category_a_id} do
    garage = fixture(:garage, @create_attrs, [category_a_id])
    assert Accounts.list_garages() == [garage]
  end

  test "get_garage! returns the garage with given id", %{category_a_id: category_a_id} do
    garage = fixture(:garage, @create_attrs, [category_a_id])
    assert Accounts.get_garage!(garage.id) == garage
  end

  test "get_garage! returns the correct associations", %{category_a_id: category_a_id} do
    garage = fixture(:garage, @create_attrs, [category_a_id])
    %{garage_categories: gc} = Accounts.get_garage!(garage.id)
    assert Enum.map(gc, fn %{id: id} -> id end) == [category_a_id]
  end

  test "create_garage/1 with valid data creates a garage", %{category_a_id: category_a_id} do
    garage_attrs = %{garage: @create_attrs, garage_categories: [category_a_id]}
    assert {:ok, %Garage{} = garage} = Accounts.create_garage(garage_attrs)
    assert garage.cnpj == "some cnpj"
    assert garage.user.email == "some@email.com"
    assert garage.name == "some name"
    assert garage.owner_name == "some owner_name"
    assert garage.phone == "some phone"
  end

  test "create_garage/1 with invalid data returns error changeset" do
    garage_attrs = %{garage: @invalid_attrs, garage_categories: []}
    assert_raise Ecto.InvalidChangesetError, fn ->
      Accounts.create_garage(garage_attrs)
    end
  end

  test "update_garage/2 with valid data updates the garage", %{category_a_id: category_a_id, category_b_id: category_b_id} do
    garage = fixture(:garage, @create_attrs, [category_a_id])
    garage_attrs = %{garage: @update_attrs, garage_categories: [category_b_id]}

    assert {:ok, garage} = Accounts.update_garage(garage, garage_attrs)
    assert %Garage{} = garage
    assert garage.cnpj == "some updated cnpj"
    assert garage.user.email == "some@updated_email.com"
    assert garage.name == "some updated name"
    assert garage.owner_name == "some updated owner_name"
    assert garage.phone == "some updated phone"

    category_ids = Enum.map(garage.garage_categories, fn %{id: id} -> id end) |> Enum.sort
    category_a_and_b_ids = Enum.sort([category_a_id, category_b_id])
    assert category_a_and_b_ids == category_ids
  end

  test "update_garage/2 with invalid data returns error changeset" do
    garage = fixture(:garage)
    garage_attrs = %{garage: @invalid_attrs, garage_categories: []}
    assert_raise Ecto.InvalidChangesetError, fn ->
     Accounts.update_garage(garage, garage_attrs)
    end
    assert garage == Accounts.get_garage!(garage.id)
  end

  test "delete_garage/1 deletes the garage" do
    garage = fixture(:garage)
    assert {:ok, %Garage{}} = Accounts.delete_garage(garage)
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_garage!(garage.id) end
  end

  test "change_garage/1 returns a garage changeset" do
    garage = fixture(:garage)
    assert %Ecto.Changeset{} = Accounts.change_garage(garage)
  end
end
