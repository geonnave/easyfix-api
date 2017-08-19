defmodule EasyFixApiWeb.GarageControllerTest do
  use EasyFixApiWeb.ConnCase

  @invalid_attrs %{
    cnpj: nil,
    email: nil,
    name: nil,
    owner_name: nil,
    password_hash: nil,
    phone: nil,
    garage_categories_ids: []}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  @tag :skip # TOOD: only an admin can list all users.. but we don't have 'admin users' yet.
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, garage_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates garage and renders garage when data is valid", %{conn: conn} do
    garage_attrs = garage_with_all_params()

    conn = post conn, garage_path(conn, :create), garage: garage_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]
    assert json_response(conn, 201)["jwt"]

    jwt = json_response(conn, 201)["jwt"]
    conn =
      conn
      |> recycle()
      |> put_req_header("authorization", "Bearer #{jwt}")
      |> get(garage_path(conn, :show, id))

    assert json_response(conn, 200)["data"]["id"] == id
    assert length(json_response(conn, 200)["data"]["garage_categories"]) == 2
    assert is_map(json_response(conn, 200)["data"]["address"])
    assert is_map(json_response(conn, 200)["data"]["bank_account"])
  end

  test "does not create garage and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, garage_path(conn, :create), garage: @invalid_attrs
    assert json_response(conn, 422)["errors"]
  end

  @tag :skip # skipping update tests for now
  test "updates chosen garage and renders garage when data is valid", %{conn: _conn} do
  end


  @tag :skip
  test "does not update chosen garage and renders errors when data is invalid", %{conn: _conn} do
  end

  test "deletes chosen garage", %{conn: conn} do
    garage = insert(:garage)

    conn =
      conn
      |> authenticate(garage.user)
      |> delete(garage_path(conn, :delete, garage))
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      conn
      |> authenticate(garage.user)
      |> get(garage_path(conn, :show, garage))
    end
  end

  def authenticate(conn, user) do
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user, :token)
    conn
    |> recycle()
    |> put_req_header("authorization", "Bearer #{jwt}")
  end
end
