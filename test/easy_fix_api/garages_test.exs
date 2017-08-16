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
    garage_categories_ids: []}

  @category_a %GarageCategory{name: "foo"}
  @category_b %GarageCategory{name: "bar"}

  setup do
    %{id: category_a_id} = Repo.insert! @category_a
    %{id: category_b_id} = Repo.insert! @category_b

    [category_a_id: category_a_id, category_b_id: category_b_id]
  end

  def fixture(:garage) do
    garage_category = insert(:garage_category)
    address = params_with_assocs(:address)
    bank_account = params_with_assocs(:bank_account)
    fixture(:garage, @create_attrs, [garage_category.id], address, bank_account)
  end

  def fixture(:garage, attrs \\ @create_attrs, cat_ids \\ [], address \\ %{}, bank_account \\ %{}) do
    {:ok, garage} =
      attrs
      |> put_in([:garage_categories_ids], cat_ids)
      |> put_in([:address], address)
      |> put_in([:bank_account], bank_account)
      |> Accounts.create_garage()

    %{garage | user: %{garage.user | password: nil}}
  end

  test "list_garages/1 returns all garages" do
    garage = fixture(:garage)
    [listed_garage] = Accounts.list_garages()
    assert listed_garage.id == garage.id
  end

  test "get_garage! returns the garage with given id" do
    garage = fixture(:garage)
    assert Accounts.get_garage!(garage.id) == garage
  end

  test "get_garage! returns the correct associations" do
    garage_category = insert(:garage_category)
    address = params_with_assocs(:address)
    bank_account = params_with_assocs(:bank_account)
    garage = fixture(:garage, @create_attrs, [garage_category.id], address, bank_account)
    %{garage_categories: gc} = Accounts.get_garage!(garage.id)
    assert Enum.map(gc, fn %{id: id} -> id end) == [garage_category.id]
  end

  test "create_garage/1 with valid data creates a garage" do
    garage_category = insert(:garage_category)
    address = params_with_assocs(:address)
    bank_account = params_with_assocs(:bank_account)

    {:ok, garage} =
      @create_attrs
      |> put_in([:garage_categories_ids], [garage_category.id])
      |> put_in([:address], address)
      |> put_in([:bank_account], bank_account)
      |> Accounts.create_garage()

    assert garage.cnpj == "some cnpj"
    assert garage.user.email == "some@email.com"
    assert garage.name == "some name"
    assert garage.owner_name == "some owner_name"
    assert garage.phone == "some phone"
  end

  test "create_garage/1 with invalid data returns error changeset" do
    {:error, _changeset} = Accounts.create_garage(@invalid_attrs)
  end

  @tag :skip # TODO: learn how to properly manage updates..
  test "update_garage/2 with valid data updates the garage" do
    garage_category = insert(:garage_category)
    address = params_with_assocs(:address)
    bank_account = params_with_assocs(:bank_account)
    garage = fixture(:garage, @create_attrs, [garage_category.id], address, bank_account)

    other_garage_category = insert(:garage_category)
    garage_attrs = put_in(@update_attrs, [:garage_categories_ids], [other_garage_category.id])
    assert {:ok, garage} = Accounts.update_garage(garage, garage_attrs)

    assert garage.cnpj == "some updated cnpj"
    assert garage.user.email == "some@updated_email.com"
    assert garage.name == "some updated name"
    assert garage.owner_name == "some updated owner_name"
    assert garage.phone == "some updated phone"

    category_ids = Enum.map(garage.garage_categories_ids, fn %{id: id} -> id end) |> Enum.sort
    category_a_and_b_ids = Enum.sort([garage_category.id, other_garage_category.id])
    assert category_a_and_b_ids == category_ids
  end

  test "update_garage/2 with invalid data returns error changeset" do
    garage = fixture(:garage)
    {:error, _changeset} = Accounts.update_garage(garage, @invalid_attrs)
    assert garage == Accounts.get_garage!(garage.id)
  end

  test "delete_garage/1 deletes the garage" do
    address = params_with_assocs(:address)
    bank_account = params_with_assocs(:bank_account)
    garage = fixture(:garage, @create_attrs, [], address, bank_account)
    assert {:ok, %Garage{}} = Accounts.delete_garage(garage)
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_garage!(garage.id) end
  end

  test "change_garage/1 returns a garage changeset" do
    garage = fixture(:garage)
    assert %Ecto.Changeset{} = Accounts.change_garage(garage)
  end
end
