defmodule EasyFixApiWeb.BudgetControllerTest do
  use EasyFixApiWeb.ConnCase

  alias EasyFixApi.Orders.Budget

  @update_attrs %{due_date: %DateTime{calendar: Calendar.ISO, day: 18, hour: 15, microsecond: {0, 6}, minute: 1, month: 5, second: 1, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2011, zone_abbr: "UTC"}, service_cost: 43}
  @invalid_attrs %{due_date: nil, service_cost: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, budget_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates budget and renders budget when data is valid", %{conn: conn} do
    garage = insert(:garage)
    diagnostic = insert(:diagnostic)
    %{part: part1} = diagnostic_parts_with_diagnostic(diagnostic) |> insert()
    %{part: part2} = diagnostic_parts_with_diagnostic(diagnostic) |> insert()
    parts = [
      %{"part_id" => part1.id, "price" => 4200, "quantity" => 1},
      %{"part_id" => part2.id, "price" => 200, "quantity" => 4},
    ]

    budget_attrs =
      string_params_for(:budget)
      |> put_in([:parts], parts)
      |> put_in([:diagnostic_id], diagnostic.id)
      |> put_in([:issuer_id], garage.id)
      |> put_in([:issuer_type], "garage")

    conn = post conn, budget_path(conn, :create), budget: budget_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, budget_path(conn, :show, id)
    data_resp = json_response(conn, 200)["data"]
    assert data_resp["id"] == id
    assert length(data_resp["parts"]) == 2
    assert data_resp["diagnostic_id"] == diagnostic.id
    assert data_resp["issuer_id"] == garage.id
    assert data_resp["issuer_type"] == "garage"
  end

  test "does not create budget and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, budget_path(conn, :create), budget: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag :skip # TODO: implement update when CRD is ready
  test "updates chosen budget and renders budget when data is valid", %{conn: conn} do
    %Budget{id: id} = budget = insert(:budget)
    conn = put conn, budget_path(conn, :update, budget), budget: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, budget_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "due_date" => %DateTime{calendar: Calendar.ISO, day: 18, hour: 15, microsecond: {0, 6}, minute: 1, month: 5, second: 1, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, year: 2011, zone_abbr: "UTC"},
      "service_cost" => 43}
  end

  test "does not update chosen budget and renders errors when data is invalid", %{conn: conn} do
    budget = insert(:budget)
    conn = put conn, budget_path(conn, :update, budget), budget: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen budget", %{conn: conn} do
    budget = insert(:budget)
    conn = delete conn, budget_path(conn, :delete, budget)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, budget_path(conn, :show, budget)
    end
  end
end
