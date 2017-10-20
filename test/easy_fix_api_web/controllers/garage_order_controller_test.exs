defmodule EasyFixApiWeb.GarageOrderControllerTest do
  use EasyFixApiWeb.ConnCase

  alias EasyFixApi.Orders

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "garage requests an order", %{conn: conn} do
    garage = insert(:garage)
    customer = insert(:customer)
    [vehicle] = customer.vehicles
    order_attrs = order_with_all_params(customer.id, vehicle.id)
    {:ok, order} = Orders.create_order_with_diagnosis(order_attrs)

    quote_attrs =
      params_for(:quote)
      |> put_in([:parts], parts_for_quote())
    conn = get conn, garage_order_path(conn, :show, garage.id, order.id), quote: quote_attrs
    data_resp = json_response(conn, 200)["data"]

    assert data_resp["diagnosis"]["id"] == order.diagnosis.id
  end

  test "garage submits a quote", %{conn: conn} do
    garage = insert(:garage)
    customer = insert(:customer)
    [vehicle] = customer.vehicles
    order_attrs = order_with_all_params(customer.id, vehicle.id)
    {:ok, order} = Orders.create_order_with_diagnosis(order_attrs)

    quote_attrs =
      params_for(:quote)
      |> put_in([:parts], parts_for_quote())
    conn = post conn, garage_order_quote_path(conn, :create, garage.id, order.id), quote: quote_attrs

    data_resp = json_response(conn, 201)["data"]

    assert is_list(data_resp["parts"])
    assert data_resp["diagnosis_id"] == order.diagnosis.id
    assert data_resp["issuer_id"] == garage.id
    assert data_resp["issuer_type"] == "garage"
  end
end
