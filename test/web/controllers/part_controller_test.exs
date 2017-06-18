defmodule EasyFixApi.Web.PartControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.Parts
  alias EasyFixApi.Parts.Part

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:part) do
    {:ok, part} = Parts.create_part(@create_attrs)
    part
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, part_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates part and renders part when data is valid", %{conn: conn} do
    conn = post conn, part_path(conn, :create), part: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, part_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some name"}
  end

  test "does not create part and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, part_path(conn, :create), part: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen part and renders part when data is valid", %{conn: conn} do
    %Part{id: id} = part = fixture(:part)
    conn = put conn, part_path(conn, :update, part), part: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, part_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some updated name"}
  end

  test "does not update chosen part and renders errors when data is invalid", %{conn: conn} do
    part = fixture(:part)
    conn = put conn, part_path(conn, :update, part), part: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen part", %{conn: conn} do
    part = fixture(:part)
    conn = delete conn, part_path(conn, :delete, part)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, part_path(conn, :show, part)
    end
  end
end
