defmodule EasyFixApi.Web.SessionControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.Accounts

  @create_garage_attrs %{
    cnpj: "some cnpj",
    email: "email@example.com",
    name: "some name",
    owner_name: "some owner_name",
    password: "some password",
    phone: "some phone"}

  test "creates a session for garage", %{conn: conn} do
    Accounts.create_garage(%{garage: @create_garage_attrs, garage_categories: []})

    conn = post conn, session_path(conn, :create), email: "email@example.com", password: "some password", user_type: "garage"
    %{"data" => %{
        "id" => _id,
        "email" => "email@example.com"
      },
      "jwt" => _jwt,
    } = json_response(conn, 201)
  end

  test "fails authorization", %{conn: conn} do
    conn = post conn, session_path(conn, :create), email: "email@example.com", password: "wrong", user_type: "garage"
    %{
      "error" => "Unable to authenticate"
    } = json_response(conn, 422)
  end
end
