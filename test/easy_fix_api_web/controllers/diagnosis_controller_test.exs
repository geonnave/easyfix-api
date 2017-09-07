defmodule EasyFixApiWeb.DiagnosisControllerTest do
  use EasyFixApiWeb.ConnCase

  alias EasyFixApi.Orders

  @create_attrs %{accepts_used_parts: true, comment: "some comment", need_tow_truck: true, status: "some status"}
  @invalid_attrs %{accepts_used_parts: nil, comment: nil, need_tow_truck: nil, status: nil}

  def fixture(:diagnosis) do
    {:ok, diagnosis} = Orders.create_diagnosis(@create_attrs)
    diagnosis
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, diagnosis_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates diagnosis and renders diagnosis when data is valid", %{conn: conn} do
    vehicle = insert(:vehicle_with_model)
    diagnosis_attrs =
      string_params_for(:diagnosis)
      |> put_in([:parts], diagnosis_parts_params(2))
      |> put_in([:vehicle_id], vehicle.id)

    conn = post conn, diagnosis_path(conn, :create), diagnosis: diagnosis_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, diagnosis_path(conn, :show, id)
    data_resp = json_response(conn, 200)["data"]
    assert data_resp["id"] == id
    assert length(data_resp["parts"]) == 2
  end

  test "does not create diagnosis and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, diagnosis_path(conn, :create), diagnosis: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen diagnosis", %{conn: conn} do
    diagnosis = insert(:diagnosis)
    conn = delete conn, diagnosis_path(conn, :delete, diagnosis)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, diagnosis_path(conn, :show, diagnosis)
    end
  end
end
