defmodule EasyFixApi.Web.BrandController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Cars
  alias EasyFixApi.Cars.Brand

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    brands = Cars.list_brands()
    render(conn, "index.json", brands: brands)
  end

  def create(conn, %{"brand" => brand_params}) do
    with {:ok, %Brand{} = brand} <- Cars.create_brand(brand_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", brand_path(conn, :show, brand))
      |> render("show.json", brand: brand)
    end
  end

  def show(conn, %{"id" => id}) do
    brand = Cars.get_brand!(id)
    render(conn, "show.json", brand: brand)
  end

  def update(conn, %{"id" => id, "brand" => brand_params}) do
    brand = Cars.get_brand!(id)

    with {:ok, %Brand{} = brand} <- Cars.update_brand(brand, brand_params) do
      render(conn, "show.json", brand: brand)
    end
  end

  def delete(conn, %{"id" => id}) do
    brand = Cars.get_brand!(id)
    with {:ok, %Brand{}} <- Cars.delete_brand(brand) do
      send_resp(conn, :no_content, "")
    end
  end
end
