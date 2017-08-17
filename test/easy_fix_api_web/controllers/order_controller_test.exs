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
      diagnostic_attrs =
        params_for(:diagnostic)
        |> put_in([:parts], diagnostic_parts_params(2))

      order_attrs =
        params_for(:order)
        |> put_in([:diagnostic], diagnostic_attrs)

      conn = post conn, order_path(conn, :create), order: order_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, order_path(conn, :show, id)
      assert json_response(conn, 200)["data"]["id"] == id
      assert json_response(conn, 200)["data"]["opening_date"] == order_attrs[:opening_date]
      assert json_response(conn, 200)["data"]["status"] == order_attrs[:status]
      assert json_response(conn, 200)["data"]["sub_status"] == order_attrs[:sub_status]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, order_path(conn, :create), order: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
