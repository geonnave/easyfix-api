defmodule EasyFixApi.Web.PartSystemView do
  use EasyFixApi.Web, :view
  alias EasyFixApi.Web.PartSystemView

  def render("index.json", %{part_systems: part_systems}) do
    %{data: render_many(part_systems, PartSystemView, "part_system.json")}
  end

  def render("show.json", %{part_system: part_system}) do
    %{data: render_one(part_system, PartSystemView, "part_system.json")}
  end

  def render("part_system.json", %{part_system: part_system}) do
    %{id: part_system.id,
      name: part_system.name}
  end
end
