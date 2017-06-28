defmodule EasyFixApi.Web.BrandController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Cars

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    brands = Cars.list_brands()
    render(conn, "index.json", brands: brands)
  end
end
