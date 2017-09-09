defmodule EasyFixApiWeb.CityController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Addresses

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params) do
    cities = Addresses.list_cities()
    render(conn, EasyFixApiWeb.CityView, "index.json", cities: cities)
  end
end
