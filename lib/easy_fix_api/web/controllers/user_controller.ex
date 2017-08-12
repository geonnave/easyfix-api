defmodule EasyFixApiWeb.UserController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Accounts
  alias EasyFixApi.Accounts.User

  action_fallback EasyFixApiWeb.FallbackController
  plug Guardian.Plug.EnsureAuthenticated,
    [handler: EasyFixApiWeb.SessionController] when not action in [:create]

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user, :token)

      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show_registration.json", user: user, jwt: jwt)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end
end
