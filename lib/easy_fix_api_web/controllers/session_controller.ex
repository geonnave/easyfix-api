defmodule EasyFixApiWeb.SessionController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Accounts
  alias EasyFixApiWeb.{SessionView, ErrorView}

  require Logger

  action_fallback EasyFixApiWeb.FallbackController

  def create(conn, params = %{"email" => email, "password" => password, "user_type" => user_type}) do
    Logger.info "Session data is: #{inspect(params)}"
    email = Accounts.User.process_email(email)
    with account when not is_nil(account) <- Accounts.get_by_email(user_type, email),
         true <- check_password(account.user, password) do
      {:ok, jwt, _full_claims} = Guardian.encode_and_sign(account.user, :token)

      conn
      |> put_status(:created)
      |> put_resp_header("authorization", "Bearer #{jwt}")
      |> render(SessionView, "show.json", account: account, jwt: jwt)
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
