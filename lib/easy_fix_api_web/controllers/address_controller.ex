defmodule EasyFixApiWeb.AddressController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Addresses
  alias EasyFixApi.Addresses.Address
  alias EasyFixApiWeb.CityView

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params) do
    addresses = Addresses.list_addresses()
    render(conn, "index.json", addresses: addresses)
  end

  def create(conn, %{"address" => address_params}) do
    with {:ok, %Address{} = address} <- Addresses.create_address(address_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", address_path(conn, :show, address))
      |> render("show.json", address: address)
    end
  end

  def show(conn, %{"id" => id}) do
    address = Addresses.get_address!(id)
    render(conn, "show.json", address: address)
  end

  def update(conn, %{"id" => id, "address" => address_params}) do
    address = Addresses.get_address!(id)

    with {:ok, %Address{} = address} <- Addresses.update_address(address, address_params) do
      render(conn, "show.json", address: address)
    end
  end

  def delete(conn, %{"id" => id}) do
    address = Addresses.get_address!(id)
    with {:ok, %Address{}} <- Addresses.delete_address(address) do
      send_resp(conn, :no_content, "")
    end
  end

  def cities(conn, _params) do
    cities = Addresses.list_cities()
    render(conn, CityView, "cities.json", cities: cities)
  end
end
