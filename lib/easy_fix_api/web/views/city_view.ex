defmodule EasyFixApi.Web.CityView do
  use EasyFixApi.Web, :view
  alias EasyFixApi.Web.CityView

  def render("cities.json", %{cities: cities}) do
    IO.inspect cities
    %{data: render_many(cities, CityView, "city.json")}
  end

  def render("city.json", %{city: city}) do
    %{id: city.id,
      city: city.name,
      state: city.state.name,
      state_id: city.state.id}
  end
end