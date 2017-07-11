defmodule EasyFixApi.Web.SessionController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Accounts
  alias EasyFixApi.Accounts.User
  alias EasyFixApi.Web.{UserView, ErrorView}

  action_fallback EasyFixApi.Web.FallbackController

  def create(conn, %{"email" => email, "password" => password}) do
    with user when not is_nil(user) <- Accounts.get_user_by(email),
         true <- check_password(user, password) do
      {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user, :token)

      conn
      |> put_status(:created)
      |> put_resp_header("authorization", "Bearer #{jwt}")
      |> render(UserView, "show_registration.json", user: user, jwt: jwt)
    else
      _err ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ErrorView, "error.json", error: "Unable to authenticate")
    end
  end

  defp check_password(user, password) do
    Comeonin.Bcrypt.checkpw(password, user.password_hash)
  end

  def delete(conn, _) do
    conn
    |> revoke_claims()
    |> send_resp(200, "")
  end

  defp revoke_claims(conn) do
    {:ok, claims} = Guardian.Plug.claims(conn)
    Guardian.Plug.current_token(conn)
    |> Guardian.revoke!(claims)

    conn
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:forbidden)
    |> render(ErrorView, "error.json", error: "Unauthenticated")
  end
end
