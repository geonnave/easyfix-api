defmodule EasyFixApi.Web.PartSystemControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.Parts
  alias EasyFixApi.Parts.PartSystem

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:part_system) do
    {:ok, part_system} = Parts.create_part_system(@create_attrs)
    part_system
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, part_system_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates part_system and renders part_system when data is valid", %{conn: conn} do
    conn = post conn, part_system_path(conn, :create), part_system: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, part_system_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some name"}
  end

  test "does not create part_system and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, part_system_path(conn, :create), part_system: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen part_system and renders part_system when data is valid", %{conn: conn} do
    %PartSystem{id: id} = part_system = fixture(:part_system)
    conn = put conn, part_system_path(conn, :update, part_system), part_system: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, part_system_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some updated name"}
  end

  test "does not update chosen part_system and renders errors when data is invalid", %{conn: conn} do
    part_system = fixture(:part_system)
    conn = put conn, part_system_path(conn, :update, part_system), part_system: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen part_system", %{conn: conn} do
    part_system = fixture(:part_system)
    conn = delete conn, part_system_path(conn, :delete, part_system)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, part_system_path(conn, :show, part_system)
    end
  end
end
