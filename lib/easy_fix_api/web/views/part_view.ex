defmodule EasyFixApiWeb.PartView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.PartView

  def render("index.json", %{parts: parts}) do
    %{data: render_many(parts, PartView, "part.json")}
  end

  def render("show.json", %{part: part}) do
    %{data: render_one(part, PartView, "part.json")}
  end

  def render("part.json", %{part: part}) do
    %{id: part.id,
      garage_category: part.garage_category.name,
      part_sub_group: part.part_sub_group.name,
      part_group: part.part_sub_group.part_group.name,
      part_system: part.part_sub_group.part_group.part_system.name,
      repair_by_fixer_part: part.repair_by_fixer_part != nil,
      name: part.name}
  end
end
