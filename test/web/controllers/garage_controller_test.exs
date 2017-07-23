defmodule EasyFixApi.Web.GarageControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.Accounts
  alias EasyFixApi.Accounts.Garage

  @create_attrs %{
    cnpj: "some cnpj",
    email: "foo@example.com",
    name: "some name",
    owner_name: "some owner_name",
    password: "some password",
    phone: "some phone",
    garage_categories_ids: []}
  @update_attrs %{
    cnpj: "some updated cnpj",
    email: "bar@example.com",
    name: "some updated name",
    owner_name: "some updated owner_name",
    password: "some updated password",
    phone: "some updated phone",
    garage_categories_ids: []}
  @invalid_attrs %{
    cnpj: nil,
    email: nil,
    name: nil,
    owner_name: nil,
    password_hash: nil,
    phone: nil,
    garage_categories_ids: []}

  def fixture(:garage, address, bank_account) do
    {:ok, garage} =
      @create_attrs
      |> put_in([:address], address)
      |> put_in([:bank_account], bank_account)
      |> Accounts.create_garage()

    garage
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  @tag :skip # TOOD: only an admin can list all users.. but we don't have 'admin users' yet.
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, garage_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates garage and renders garage when data is valid", %{conn: conn} do
    address = params_with_assocs(:address)
    bank_account = params_with_assocs(:bank_account)
    garage_attrs =
      @create_attrs
      |> put_in([:address], address)
      |> put_in([:bank_account], bank_account)

    conn = post conn, garage_path(conn, :create), garage: garage_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]
    assert json_response(conn, 201)["jwt"]

    jwt = json_response(conn, 201)["jwt"]
    conn =
      conn
      |> recycle()
      |> put_req_header("authorization", "Bearer #{jwt}")
      |> get(garage_path(conn, :show, id))
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
    assert json_response(conn, 422)["errors"]
  end

  @tag :skip # skipping update tests for now
  test "updates chosen garage and renders garage when data is valid", %{conn: conn} do
    address = params_with_assocs(:address)
    bank_account = params_with_assocs(:bank_account)
    %Garage{id: id} = garage = fixture(:garage, address, bank_account)

    conn =
      conn
      |> authenticate(garage.user)
      |> put(garage_path(conn, :update, garage), garage: @update_attrs)
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn =
      conn
      |> authenticate(garage.user)
      |> get(garage_path(conn, :show, id))
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
    address = params_with_assocs(:address)
    bank_account = params_with_assocs(:bank_account)
    garage = fixture(:garage, address, bank_account)

    conn =
      conn
      |> authenticate(garage.user)
      |> put(garage_path(conn, :update, garage), garage: @invalid_attrs)

    assert json_response(conn, 422)["errors"]
  end

  test "deletes chosen garage", %{conn: conn} do
    address = params_with_assocs(:address)
    bank_account = params_with_assocs(:bank_account)
    garage = fixture(:garage, address, bank_account)

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
