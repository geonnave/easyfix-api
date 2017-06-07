defmodule EasyFixApi.Web.BrandController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.StaticData
  alias EasyFixApi.StaticData.Brand

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    brands = StaticData.list_brands()
    render(conn, "index.json", brands: brands)
  end

  def create(conn, %{"brand" => brand_params}) do
    with {:ok, %Brand{} = brand} <- StaticData.create_brand(brand_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", brand_path(conn, :show, brand))
      |> render("show.json", brand: brand)
    end
  end

  def show(conn, %{"id" => id}) do
    brand = StaticData.get_brand!(id)
    render(conn, "show.json", brand: brand)
  end

  def update(conn, %{"id" => id, "brand" => brand_params}) do
    brand = StaticData.get_brand!(id)

    with {:ok, %Brand{} = brand} <- StaticData.update_brand(brand, brand_params) do
      render(conn, "show.json", brand: brand)
    end
  end

  def delete(conn, %{"id" => id}) do
    brand = StaticData.get_brand!(id)
    with {:ok, %Brand{}} <- StaticData.delete_brand(brand) do
      send_resp(conn, :no_content, "")
    end
  end
end
