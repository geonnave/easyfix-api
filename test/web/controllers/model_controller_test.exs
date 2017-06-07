defmodule EasyFixApi.Web.ModelControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.StaticData
  alias EasyFixApi.StaticData.Model

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:model) do
    {:ok, model} = StaticData.create_model(@create_attrs)
    model
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, model_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates model and renders model when data is valid", %{conn: conn} do
    conn = post conn, model_path(conn, :create), model: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, model_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some name"}
  end

  test "does not create model and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, model_path(conn, :create), model: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen model and renders model when data is valid", %{conn: conn} do
    %Model{id: id} = model = fixture(:model)
    conn = put conn, model_path(conn, :update, model), model: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, model_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "name" => "some updated name"}
  end

  test "does not update chosen model and renders errors when data is invalid", %{conn: conn} do
    model = fixture(:model)
    conn = put conn, model_path(conn, :update, model), model: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen model", %{conn: conn} do
    model = fixture(:model)
    conn = delete conn, model_path(conn, :delete, model)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, model_path(conn, :show, model)
    end
  end
end
