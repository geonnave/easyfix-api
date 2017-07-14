defmodule EasyFixApi.Web.AddressController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Addresses
  alias EasyFixApi.Addresses.Address

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    addresses = Addresses.list_addresses()
    render(conn, "index.json", addresses: addresses)
  end

  def create(conn, %{"address" => address_params}) do
    address_params = 
      %{
        address: address_params,
        city: address_params["city"],
        user: address_params["user"]
      }
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
end
