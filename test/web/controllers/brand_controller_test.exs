defmodule EasyFixApi.Web.BrandControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.StaticData
  alias EasyFixApi.StaticData.Brand

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:brand) do
    {:ok, brand} = StaticData.create_brand(@create_attrs)
    brand
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, brand_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates brand and renders brand when data is valid", %{conn: conn} do
    conn = post conn, brand_path(conn, :create), brand: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, brand_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some name"}
  end

  test "does not create brand and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, brand_path(conn, :create), brand: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen brand and renders brand when data is valid", %{conn: conn} do
    %Brand{id: id} = brand = fixture(:brand)
    conn = put conn, brand_path(conn, :update, brand), brand: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, brand_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some updated name"}
  end

  test "does not update chosen brand and renders errors when data is invalid", %{conn: conn} do
    brand = fixture(:brand)
    conn = put conn, brand_path(conn, :update, brand), brand: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen brand", %{conn: conn} do
    brand = fixture(:brand)
    conn = delete conn, brand_path(conn, :delete, brand)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, brand_path(conn, :show, brand)
    end
  end
end
