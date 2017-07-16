defmodule EasyFixApi.Web.GarageController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Accounts
  alias EasyFixApi.Accounts.Garage

  action_fallback EasyFixApi.Web.FallbackController
  plug Guardian.Plug.EnsureAuthenticated,
    [handler: EasyFixApi.Web.SessionController] when not action in [:create]

  def index(conn, _params) do
    garages = Accounts.list_garages()
    render(conn, "index.json", garages: garages)
  end

  def create(conn, %{"garage" => garage_params}) do
    with {:ok, %Garage{} = garage} <- Accounts.create_garage(garage_params) do
      garage = Accounts.garage_preload(garage, :garage_categories)
      {:ok, jwt, _full_claims} = Guardian.encode_and_sign(garage.user, :token)

      conn
      |> put_status(:created)
      |> put_resp_header("location", garage_path(conn, :show, garage))
      |> render("show_registration.json", garage: garage, jwt: jwt)
    end
  end

  def show(conn, %{"id" => id}) do
    garage = Accounts.get_garage!(id)
    render(conn, "show.json", garage: garage)
  end

  def update(conn, %{"id" => id, "garage" => garage_params}) do
    garage = Accounts.get_garage!(id)
    with {:ok, %Garage{} = garage} <- Accounts.update_garage(garage, garage_params) do
      render(conn, "show.json", garage: garage)
    end
  end

  def delete(conn, %{"id" => id}) do
    garage = Accounts.get_garage!(id)
    with {:ok, %Garage{}} <- Accounts.delete_garage(garage) do
      send_resp(conn, :no_content, "")
    end
  end
end
