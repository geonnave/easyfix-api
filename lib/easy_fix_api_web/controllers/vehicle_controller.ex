defmodule EasyFixApiWeb.VehicleController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Cars
  alias EasyFixApi.Cars.Vehicle

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params) do
    vehicle = Cars.list_vehicle()
    render(conn, "index.json", vehicle: vehicle)
  end

  def create(conn, %{"vehicle" => vehicle_params}) do
    with {:ok, %Vehicle{} = vehicle} <- Cars.create_vehicle(vehicle_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", vehicle_path(conn, :show, vehicle))
      |> render("show.json", vehicle: vehicle)
    end
  end

  def show(conn, %{"id" => id}) do
    vehicle = Cars.get_vehicle!(id)
    render(conn, "show.json", vehicle: vehicle)
  end

  def update(conn, %{"id" => id, "vehicle" => vehicle_params}) do
    vehicle = Cars.get_vehicle!(id)

    with {:ok, %Vehicle{} = vehicle} <- Cars.update_vehicle(vehicle, vehicle_params) do
      render(conn, "show.json", vehicle: vehicle)
    end
  end

  def delete(conn, %{"id" => id}) do
    vehicle = Cars.get_vehicle!(id)
    with {:ok, %Vehicle{}} <- Cars.delete_vehicle(vehicle) do
      send_resp(conn, :no_content, "")
    end
  end
end
