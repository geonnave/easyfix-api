defmodule EasyFixApi.Web.PartGroupControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.Parts
  alias EasyFixApi.Parts.PartGroup

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:part_group) do
    {:ok, part_group} = Parts.create_part_group(@create_attrs)
    part_group
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, part_group_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates part_group and renders part_group when data is valid", %{conn: conn} do
    conn = post conn, part_group_path(conn, :create), part_group: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, part_group_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some name"}
  end

  test "does not create part_group and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, part_group_path(conn, :create), part_group: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen part_group and renders part_group when data is valid", %{conn: conn} do
    %PartGroup{id: id} = part_group = fixture(:part_group)
    conn = put conn, part_group_path(conn, :update, part_group), part_group: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, part_group_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some updated name"}
  end

  test "does not update chosen part_group and renders errors when data is invalid", %{conn: conn} do
    part_group = fixture(:part_group)
    conn = put conn, part_group_path(conn, :update, part_group), part_group: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen part_group", %{conn: conn} do
    part_group = fixture(:part_group)
    conn = delete conn, part_group_path(conn, :delete, part_group)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, part_group_path(conn, :show, part_group)
    end
  end
end
