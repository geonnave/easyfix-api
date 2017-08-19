defmodule EasyFixApiWeb.SessionControllerTest do
  use EasyFixApiWeb.ConnCase

  alias EasyFixApi.Accounts

  @create_garage_attrs %{
    cnpj: "some cnpj",
    email: "email@example.com",
    name: "some name",
    owner_name: "some owner_name",
    password: "some password",
    garage_categories_ids: [],
    phone: "some phone"}

  test "creates a session for garage", %{conn: conn} do
    address = params_with_assocs(:address)
    bank_account = params_with_assocs(:bank_account)

    {:ok, _garage} =
      @create_garage_attrs
      |> put_in([:address], address)
      |> put_in([:bank_account], bank_account)
      |> Accounts.create_garage()

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
