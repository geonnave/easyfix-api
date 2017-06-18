defmodule EasyFixApi.Web.GarageCategoryControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.Parts
  alias EasyFixApi.Parts.GarageCategory

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:garage_category) do
    {:ok, garage_category} = Parts.create_garage_category(@create_attrs)
    garage_category
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, garage_category_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates garage_category and renders garage_category when data is valid", %{conn: conn} do
    conn = post conn, garage_category_path(conn, :create), garage_category: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, garage_category_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some name"}
  end

  test "does not create garage_category and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, garage_category_path(conn, :create), garage_category: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen garage_category and renders garage_category when data is valid", %{conn: conn} do
    %GarageCategory{id: id} = garage_category = fixture(:garage_category)
    conn = put conn, garage_category_path(conn, :update, garage_category), garage_category: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, garage_category_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some updated name"}
  end

  test "does not update chosen garage_category and renders errors when data is invalid", %{conn: conn} do
    garage_category = fixture(:garage_category)
    conn = put conn, garage_category_path(conn, :update, garage_category), garage_category: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen garage_category", %{conn: conn} do
    garage_category = fixture(:garage_category)
    conn = delete conn, garage_category_path(conn, :delete, garage_category)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, garage_category_path(conn, :show, garage_category)
    end
  end
end
