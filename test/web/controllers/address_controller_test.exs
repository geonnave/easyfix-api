defmodule EasyFixApi.Web.AddressControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.Addresses
  alias EasyFixApi.Addresses.Address

  @create_attrs %{address_line1: "some address_line1", address_line2: "some address_line2", neighborhood: "some neighborhood", postal_code: "some postal_code"}
  @update_attrs %{address_line1: "some updated address_line1", address_line2: "some updated address_line2", neighborhood: "some updated neighborhood", postal_code: "some updated postal_code"}
  @invalid_attrs %{address_line1: nil, address_line2: nil, neighborhood: nil, postal_code: nil}

  def fixture(:address) do
    {:ok, address} = Addresses.create_address(@create_attrs)
    address
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, address_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates address and renders address when data is valid", %{conn: conn} do
    conn = post conn, address_path(conn, :create), address: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, address_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "address_line1" => "some address_line1",
      "address_line2" => "some address_line2",
      "neighborhood" => "some neighborhood",
      "postal_code" => "some postal_code"}
  end

  test "does not create address and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, address_path(conn, :create), address: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen address and renders address when data is valid", %{conn: conn} do
    %Address{id: id} = address = fixture(:address)
    conn = put conn, address_path(conn, :update, address), address: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, address_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "address_line1" => "some updated address_line1",
      "address_line2" => "some updated address_line2",
      "neighborhood" => "some updated neighborhood",
      "postal_code" => "some updated postal_code"}
  end

  test "does not update chosen address and renders errors when data is invalid", %{conn: conn} do
    address = fixture(:address)
    conn = put conn, address_path(conn, :update, address), address: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen address", %{conn: conn} do
    address = fixture(:address)
    conn = delete conn, address_path(conn, :delete, address)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, address_path(conn, :show, address)
    end
  end
end
