defmodule EasyFixApi.Web.GarageControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.Garages
  alias EasyFixApi.Garages.Garage

  @create_attrs %{
    cnpj: "some cnpj",
    email: "foo@example.com",
    name: "some name",
    owner_name: "some owner_name",
    password: "some password",
    phone: "some phone",
    garage_categories: []}
  @update_attrs %{
    cnpj: "some updated cnpj",
    email: "bar@example.com",
    name: "some updated name",
    owner_name: "some updated owner_name",
    password: "some updated password",
    phone: "some updated phone",
    garage_categories: []}
  @invalid_attrs %{
    cnpj: nil,
    email: nil,
    name: nil,
    owner_name: nil,
    password_hash: nil,
    phone: nil,
    garage_categories: []}

  def fixture(:garage) do
    {:ok, garage} = Garages.create_garage(%{garage: @create_attrs, garage_categories: []})
    garage
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, garage_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates garage and renders garage when data is valid", %{conn: conn} do
    conn = post conn, garage_path(conn, :create), garage: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, garage_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "cnpj" => "some cnpj",
      "email" => "foo@example.com",
      "name" => "some name",
      "owner_name" => "some owner_name",
      "phone" => "some phone",
      "garage_categories" => []}
  end

  test "does not create garage and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, garage_path(conn, :create), garage: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen garage and renders garage when data is valid", %{conn: conn} do
    %Garage{id: id} = garage = fixture(:garage)
    conn = put conn, garage_path(conn, :update, garage), garage: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, garage_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "cnpj" => "some updated cnpj",
      "email" => "bar@example.com",
      "name" => "some updated name",
      "owner_name" => "some updated owner_name",
      "phone" => "some updated phone",
      "garage_categories" => []}
  end

  test "does not update chosen garage and renders errors when data is invalid", %{conn: conn} do
    garage = fixture(:garage)
    conn = put conn, garage_path(conn, :update, garage), garage: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen garage", %{conn: conn} do
    garage = fixture(:garage)
    conn = delete conn, garage_path(conn, :delete, garage)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, garage_path(conn, :show, garage)
    end
  end
end
