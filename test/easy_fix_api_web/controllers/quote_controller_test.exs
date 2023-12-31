defmodule EasyFixApiWeb.QuoteControllerTest do
  use EasyFixApiWeb.ConnCase

  alias EasyFixApi.Orders.Quote

  @update_attrs %{due_date: %DateTime{calendar: Calendar.ISO, day: 18, hour: 15, microsecond: {0, 6}, minute: 1, month: 5, second: 1, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2011, zone_abbr: "UTC"}, service_cost: 43}
  @invalid_attrs %{due_date: nil, service_cost: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, quote_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates quote and renders quote when data is valid", %{conn: conn} do
    garage = insert(:garage)
    diagnosis = insert(:diagnosis)
    %{part: part1} = diagnosis_parts_with_diagnosis(diagnosis) |> insert()
    %{part: part2} = diagnosis_parts_with_diagnosis(diagnosis) |> insert()
    parts = [
      %{"part_id" => part1.id, "price" => 4200, "quantity" => 1},
      %{"part_id" => part2.id, "price" => 200, "quantity" => 4},
    ]

    quote_attrs =
      string_params_for(:quote)
      |> put_in([:parts], parts)
      |> put_in([:diagnosis_id], diagnosis.id)
      |> put_in([:issuer_id], garage.id)
      |> put_in([:issuer_type], "garage")

    conn = post conn, quote_path(conn, :create), quote: quote_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, quote_path(conn, :show, id)
    data_resp = json_response(conn, 200)["data"]
    assert data_resp["id"] == id
    assert length(data_resp["parts"]) == 2
    assert data_resp["diagnosis_id"] == diagnosis.id
    assert data_resp["issuer_id"] == garage.id
    assert data_resp["issuer_type"] == "garage"
  end

  test "does not create quote and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, quote_path(conn, :create), quote: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag :skip # TODO: implement update when CRD is ready
  test "updates chosen quote and renders quote when data is valid", %{conn: conn} do
    %Quote{id: id} = quote = insert(:quote)
    conn = put conn, quote_path(conn, :update, quote), quote: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, quote_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "due_date" => %DateTime{calendar: Calendar.ISO, day: 18, hour: 15, microsecond: {0, 6}, minute: 1, month: 5, second: 1, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2011, zone_abbr: "UTC"},
      "service_cost" => 43}
  end

  test "deletes chosen quote", %{conn: conn} do
    quote = insert(:quote)
    conn = delete conn, quote_path(conn, :delete, quote)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, quote_path(conn, :show, quote)
    end
  end
end
