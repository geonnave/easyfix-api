defmodule EasyFixApiWeb.VehicleView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.VehicleView

  def render("index.json", %{vehicle: vehicle}) do
    %{data: render_many(vehicle, VehicleView, "vehicle.json")}
  end

  def render("show.json", %{vehicle: vehicle}) do
    %{data: render_one(vehicle, VehicleView, "vehicle.json")}
  end

  def render("vehicle.json", %{vehicle: vehicle}) do
    %{id: vehicle.id,
      production_year: vehicle.production_year,
      model_year: vehicle.model_year,
      plate: vehicle.plate,
      model: vehicle.model.name,
      brand: vehicle.brand.name,
    }
  end
end
