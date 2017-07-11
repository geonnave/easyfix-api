defmodule EasyFixApi.Web.UserControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.Accounts

  @create_attrs %{email: "some@email.com", password: "some password"}
  @invalid_attrs %{email: nil, password: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  @tag :skip # TOOD: only an admin can list all users.. but we don't have 'admin users' yet.
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates user and renders user when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    jwt = json_response(conn, 201)["jwt"]
    conn =
      conn
      |> recycle()
      |> put_req_header("authorization", "Bearer #{jwt}")
      |> get(user_path(conn, :show, id))
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "email" => "some@email.com"}
  end

  test "does not create user and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end
end
