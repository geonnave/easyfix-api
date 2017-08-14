defmodule EasyFixApiWeb.OrderControllerTest do
  use EasyFixApiWeb.ConnCase

  alias EasyFixApi.Orders
  alias EasyFixApi.Orders.Order

  @create_attrs %{conclusion_date: "2010-04-17 14:00:00.000000Z", opening_date: "2010-04-17 14:00:00.000000Z", status: "some status", sub_status: "some sub_status"}
  @update_attrs %{conclusion_date: "2011-05-18 15:01:01.000000Z", opening_date: "2011-05-18 15:01:01.000000Z", status: "some updated status", sub_status: "some updated sub_status"}
  @invalid_attrs %{conclusion_date: nil, opening_date: nil, status: nil, sub_status: nil}

  def fixture(:order) do
    {:ok, order} = Orders.create_order(@create_attrs)
    order
  end

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
      conn = post conn, order_path(conn, :create), order: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, order_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "conclusion_date" => "2010-04-17T14:00:00.000000Z",
        "opening_date" => "2010-04-17T14:00:00.000000Z",
        "status" => "some status",
        "sub_status" => "some sub_status"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, order_path(conn, :create), order: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update order" do
    setup [:create_order]

    test "renders order when data is valid", %{conn: conn, order: %Order{id: id} = order} do
      conn = put conn, order_path(conn, :update, order), order: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, order_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "conclusion_date" => "2011-05-18T15:01:01.000000Z",
        "opening_date" => "2011-05-18T15:01:01.000000Z",
        "status" => "some updated status",
        "sub_status" => "some updated sub_status"}
    end

    test "renders errors when data is invalid", %{conn: conn, order: order} do
      conn = put conn, order_path(conn, :update, order), order: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete order" do
    setup [:create_order]

    test "deletes chosen order", %{conn: conn, order: order} do
      conn = delete conn, order_path(conn, :delete, order)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, order_path(conn, :show, order)
      end
    end
  end

  defp create_order(_) do
    order = fixture(:order)
    {:ok, order: order}
  end
end
