defmodule EasyFixApiWeb.CityView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.CityView

  def render("index.json", %{cities: cities}) do
    %{data: render_many(cities, CityView, "city.json")}
  end

  def render("city.json", %{city: city}) do
    %{id: city.id,
      city: city.name,
      state: city.state.name,
      state_id: city.state.id}
  end
end