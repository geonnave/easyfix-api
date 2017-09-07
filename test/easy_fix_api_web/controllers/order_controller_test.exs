defmodule EasyFixApiWeb.OrderControllerTest do
  use EasyFixApiWeb.ConnCase

  @invalid_attrs %{conclusion_date: nil, opening_date: nil, status: nil, sub_status: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all orders", %{conn: conn} do
      conn = get conn, order_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create order" do
    test "renders order when data is valid", %{conn: conn} do
      customer = insert(:customer)
      [vehicle] = customer.vehicles

      diagnosis_attrs =
        params_for(:diagnosis)
        |> put_in([:parts], diagnosis_parts_params(2))
        |> put_in([:vehicle_id], vehicle.id)

      order_attrs =
        params_for(:order)
        |> put_in([:diagnosis], diagnosis_attrs)
        |> put_in([:customer_id], customer.id)

      conn = post conn, order_path(conn, :create), order: order_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, order_path(conn, :show, id)
      assert json_response(conn, 200)["data"]["id"] == id
      assert json_response(conn, 200)["data"]["opening_date"] == order_attrs[:opening_date]
      assert json_response(conn, 200)["data"]["status"] == order_attrs[:status]
      assert json_response(conn, 200)["data"]["sub_status"] == order_attrs[:sub_status]
      assert json_response(conn, 200)["data"]["customer_id"] == order_attrs[:customer_id]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, order_path(conn, :create), order: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
