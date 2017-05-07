defmodule EasyFixApi.Web.OBDCodeControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.OBDCodes
  alias EasyFixApi.OBDCodes.OBDCode

  @create_attrs %{code: "some code", description: "some description"}
  @update_attrs %{code: "some code", description: "some updated description"}
  @invalid_attrs %{code: nil, description: nil}

  def fixture(:obd_code) do
    {:ok, obd_code} = OBDCodes.create_obd_code(@create_attrs)
    obd_code
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, obd_code_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates obd_code and renders obd_code when data is valid", %{conn: conn} do
    conn = post conn, obd_code_path(conn, :create), obd_code: @create_attrs
    assert %{"code" => code} = json_response(conn, 201)["data"]

    conn = get conn, obd_code_path(conn, :show, code)
    assert json_response(conn, 200)["data"] == %{
      "code" => "some code",
      "description" => "some description"}
  end

  test "does not create obd_code and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, obd_code_path(conn, :create), obd_code: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen obd_code and renders obd_code when data is valid", %{conn: conn} do
    %OBDCode{code: code} = obd_code = fixture(:obd_code)
    conn = put conn, obd_code_path(conn, :update, obd_code), obd_code: @update_attrs
    assert %{"code" => ^code} = json_response(conn, 200)["data"]

    conn = get conn, obd_code_path(conn, :show, code)
    assert json_response(conn, 200)["data"] == %{
      "code" => "some code",
      "description" => "some updated description"}
  end

  test "does not update chosen obd_code and renders errors when data is invalid", %{conn: conn} do
    obd_code = fixture(:obd_code)
    conn = put conn, obd_code_path(conn, :update, obd_code), obd_code: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen obd_code", %{conn: conn} do
    obd_code = fixture(:obd_code)
    conn = delete conn, obd_code_path(conn, :delete, obd_code)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, obd_code_path(conn, :show, obd_code)
    end
  end
end
