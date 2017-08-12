defmodule EasyFixApiWeb.PartGroupView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.PartGroupView

  def render("index.json", %{part_groups: part_groups}) do
    %{data: render_many(part_groups, PartGroupView, "part_group.json")}
  end

  def render("show.json", %{part_group: part_group}) do
    %{data: render_one(part_group, PartGroupView, "part_group.json")}
  end

  def render("part_group.json", %{part_group: part_group}) do
    %{id: part_group.id,
      name: part_group.name}
  end
end
