defmodule EasyFixApiWeb.PartSubGroupView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.PartSubGroupView

  def render("index.json", %{part_sub_groups: part_sub_groups}) do
    %{data: render_many(part_sub_groups, PartSubGroupView, "part_sub_group.json")}
  end

  def render("show.json", %{part_sub_group: part_sub_group}) do
    %{data: render_one(part_sub_group, PartSubGroupView, "part_sub_group.json")}
  end

  def render("part_sub_group.json", %{part_sub_group: part_sub_group}) do
    %{id: part_sub_group.id,
      name: part_sub_group.name}
  end
end
