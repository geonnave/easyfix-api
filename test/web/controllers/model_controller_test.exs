defmodule EasyFixApi.Web.ModelControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.Cars

  @create_attrs %{name: "some name"}
  # @update_attrs %{name: "some updated name"}
  # @invalid_attrs %{name: nil}

  def fixture(:model) do
    {:ok, model} = Cars.create_model(@create_attrs)
    model
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, model_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end
end
