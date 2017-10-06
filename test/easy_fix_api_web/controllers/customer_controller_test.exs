defmodule EasyFixApiWeb.CustomerControllerTest do
  use EasyFixApiWeb.ConnCase

  alias EasyFixApi.Accounts.Customer

  @update_attrs %{accept_easyfix_policy: "2011-05-18 15:01:01.000000Z", cpf: "some updated cpf", name: "some updated name", phone: "some updated phone"}
  @invalid_attrs %{accept_easyfix_policy: nil, cpf: nil, name: nil, phone: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  @tag :skip # TOOD: only an admin can list all users.. but we don't have 'admin users' yet.
  describe "index" do
    test "lists all customers", %{conn: conn} do
      conn = get conn, customer_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create customer" do
    test "renders customer when data is valid", %{conn: conn} do
      customer_attrs = customer_with_all_params()
      conn = post conn, customer_path(conn, :create), customer: customer_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert json_response(conn, 201)["jwt"]

      jwt = json_response(conn, 201)["jwt"]
      conn = 
        conn
        |> recycle()
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> get(customer_path(conn, :show, id))

      assert json_response(conn, 200)["data"]["id"] == id
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, customer_path(conn, :create), customer: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update customer" do
    setup [:create_customer]

    @tag :skip
    test "renders customer when data is valid", %{conn: conn, customer: %Customer{id: id} = customer} do
      conn = put conn, customer_path(conn, :update, customer), customer: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, customer_path(conn, :show, id)
      assert json_response(conn, 200)["data"]["id"] == id
      assert json_response(conn, 200)["data"]["name"] == "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, customer: customer} do
      conn =
        conn
        |> authenticate(customer.user)
        |> put(customer_path(conn, :update, customer), customer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete customer" do
    setup [:create_customer]

    test "deletes chosen customer", %{conn: conn, customer: customer} do
      conn =
        conn
        |> authenticate(customer.user)
        |> delete(customer_path(conn, :delete, customer))

      assert response(conn, 204)
      assert_error_sent 404, fn ->
        conn
        |> authenticate(customer.user)
        |> get(customer_path(conn, :show, customer))
      end
    end
  end

  defp create_customer(_) do
    customer = insert(:customer)
    {:ok, customer: customer}
  end

  def authenticate(conn, user) do
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user, :token)
    conn
    |> recycle()
    |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
