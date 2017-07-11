defmodule EasyFixApi.Web.SessionControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.Accounts.User
  alias EasyFixApi.{Repo}

  test "creates a session", %{conn: conn} do
    %User{}
    |> User.registration_changeset(%{
      email: "email@example.com",
      password: "password"
    })
    |> Repo.insert!

    conn = post conn, session_path(conn, :create), email: "email@example.com", password: "password"
    %{"data" => %{
        "id" => _id,
        "email" => "email@example.com"
      },
      "jwt" => _jwt,
    } = json_response(conn, 201)
  end

  test "fails authorization", %{conn: conn} do
    conn = post conn, session_path(conn, :create), email: "email@example.com", password: "wrong"
    %{
      "error" => "Unable to authenticate"
    } = json_response(conn, 422)
  end
end
