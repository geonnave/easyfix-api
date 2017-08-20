defmodule EasyFixApiWeb.DiagnosticControllerTest do
  use EasyFixApiWeb.ConnCase

  alias EasyFixApi.Orders

  @create_attrs %{accepts_used_parts: true, comment: "some comment", need_tow_truck: true, status: "some status"}
  @invalid_attrs %{accepts_used_parts: nil, comment: nil, need_tow_truck: nil, status: nil}

  def fixture(:diagnostic) do
    {:ok, diagnostic} = Orders.create_diagnostic(@create_attrs)
    diagnostic
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, diagnostic_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates diagnostic and renders diagnostic when data is valid", %{conn: conn} do
    vehicle = insert(:vehicle_with_model)
    diagnostic_attrs =
      string_params_for(:diagnostic)
      |> put_in([:parts], diagnostic_parts_params(2))
      |> put_in([:vehicle_id], vehicle.id)

    conn = post conn, diagnostic_path(conn, :create), diagnostic: diagnostic_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, diagnostic_path(conn, :show, id)
    data_resp = json_response(conn, 200)["data"]
    assert data_resp["id"] == id
    assert length(data_resp["parts"]) == 2
  end

  test "does not create diagnostic and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, diagnostic_path(conn, :create), diagnostic: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen diagnostic", %{conn: conn} do
    diagnostic = insert(:diagnostic)
    conn = delete conn, diagnostic_path(conn, :delete, diagnostic)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, diagnostic_path(conn, :show, diagnostic)
    end
  end
end
