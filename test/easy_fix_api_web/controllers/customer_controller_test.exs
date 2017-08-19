defmodule EasyFixApiWeb.CustomerControllerTest do
  use EasyFixApiWeb.ConnCase

  alias EasyFixApi.Accounts
  alias EasyFixApi.Accounts.Customer

  @create_attrs %{accept_easyfix_policy: "2010-04-17 14:00:00.000000Z", cpf: "some cpf", name: "some name", phone: "some phone"}
  @update_attrs %{accept_easyfix_policy: "2011-05-18 15:01:01.000000Z", cpf: "some updated cpf", name: "some updated name", phone: "some updated phone"}
  @invalid_attrs %{accept_easyfix_policy: nil, cpf: nil, name: nil, phone: nil}

  def fixture(:customer) do
    {:ok, customer} = Accounts.create_customer(@create_attrs)
    customer
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all customers", %{conn: conn} do
      conn = get conn, customer_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create customer" do
    test "renders customer when data is valid", %{conn: conn} do
      conn = post conn, customer_path(conn, :create), customer: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, customer_path(conn, :show, id)
      assert json_response(conn, 200)["data"]["id"] == id
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, customer_path(conn, :create), customer: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  @tag :skip
  describe "update customer" do
    setup [:create_customer]

    test "renders customer when data is valid", %{conn: conn, customer: %Customer{id: id} = customer} do
      conn = put conn, customer_path(conn, :update, customer), customer: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, customer_path(conn, :show, id)
      assert json_response(conn, 200)["data"]["id"] == id
      assert json_response(conn, 200)["data"]["name"] == "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, customer: customer} do
      conn = put conn, customer_path(conn, :update, customer), customer: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete customer" do
    setup [:create_customer]

    test "deletes chosen customer", %{conn: conn, customer: customer} do
      conn = delete conn, customer_path(conn, :delete, customer)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, customer_path(conn, :show, customer)
      end
    end
  end

  defp create_customer(_) do
    customer = fixture(:customer)
    {:ok, customer: customer}
  end
end
