defmodule EasyFixApi.CustomersTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Accounts

  alias EasyFixApi.Accounts.Customer

  @update_attrs %{accept_easyfix_policy: "2011-05-18 15:01:01.000000Z", cpf: "some updated cpf", name: "some updated name", phone: "some updated phone"}
  @invalid_attrs %{accept_easyfix_policy: nil, cpf: nil, name: nil, phone: nil}

  test "list_customers/0 returns all customers" do
    insert(:customer)
    assert length(Accounts.list_customers()) == 1
  end

  test "get_customer!/1 returns the customer with given id" do
    customer = insert(:customer)
    assert Accounts.get_customer!(customer.id).id == customer.id
  end

  test "create_customer/1 with valid data creates a customer" do
    customer_attrs = customer_with_all_params()
    assert {:ok, %Customer{} = customer} = Accounts.create_customer(customer_attrs)

    {:ok, accept_easyfix_policy, _} = DateTime.from_iso8601 customer_attrs[:accept_easyfix_policy]
    assert customer.accept_easyfix_policy == accept_easyfix_policy
    assert customer.cpf == customer_attrs[:cpf]
    assert customer.user.email == customer_attrs[:email]
    assert is_map(customer.address)
    assert length(customer.vehicles) == 1
    assert is_binary(customer.indication_code)
  end

  test "create_customer/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create_customer(@invalid_attrs)
  end

  @tag :skip # TODO 
  test "update_customer/2 with valid data updates the customer" do
    customer = insert(:customer)
    assert {:ok, customer} = Accounts.update_customer(customer, @update_attrs)
    assert %Customer{} = customer
    assert customer.accept_easyfix_policy == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
    assert customer.cpf == "some updated cpf"
    assert customer.name == "some updated name"
    assert customer.phone == "some updated phone"
  end

  @tag :skip # TODO 
  test "update_customer/2 with invalid data returns error changeset" do
    customer = insert(:customer)
    assert {:error, %Ecto.Changeset{}} = Accounts.update_customer(customer, @invalid_attrs)
    assert customer == Accounts.get_customer!(customer.id)
  end

  test "delete_customer/1 deletes the customer" do
    customer = insert(:customer)
    assert {:ok, %Customer{}} = Accounts.delete_customer(customer)
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_customer!(customer.id) end
  end
end
