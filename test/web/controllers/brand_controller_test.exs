defmodule EasyFixApi.Web.BrandControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.Cars

  @create_attrs %{name: "some name"}
  # @update_attrs %{name: "some updated name"}
  # @invalid_attrs %{name: nil}

  def fixture(:brand) do
    {:ok, brand} = Cars.create_brand(@create_attrs)
    brand
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, brand_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end
end
