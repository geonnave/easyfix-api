defmodule EasyFixApi.Web.GarageController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Garages
  alias EasyFixApi.Garages.Garage

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    garages = Garages.list_garages()
    render(conn, "index.json", garages: garages)
  end

  def create(conn, %{"garage" => garage_params}) do
    garage_params = %{garage: garage_params, garage_categories: garage_params["garage_categories"]}
    with {:ok, %Garage{} = garage} <- Garages.create_garage(garage_params) do
      garage = Garages.garage_preload(garage, :garage_categories)
      {:ok, jwt, _full_claims} = Guardian.encode_and_sign(garage.user, :token)

      conn
      |> put_status(:created)
      |> put_resp_header("location", garage_path(conn, :show, garage))
      |> render("show_registration.json", garage: garage, jwt: jwt)
    end
  end

  def show(conn, %{"id" => id}) do
    garage = Garages.get_garage!(id)
    render(conn, "show.json", garage: garage)
  end

  def update(conn, %{"id" => id, "garage" => garage_params}) do
    garage_params = %{garage: garage_params, garage_categories: garage_params["garage_categories"]}
    garage = Garages.get_garage!(id)

    with {:ok, %Garage{} = garage} <- Garages.update_garage(garage, garage_params) do
      render(conn, "show.json", garage: garage)
    end
  end

  def delete(conn, %{"id" => id}) do
    garage = Garages.get_garage!(id)
    with {:ok, %Garage{}} <- Garages.delete_garage(garage) do
      send_resp(conn, :no_content, "")
    end
  end
end
