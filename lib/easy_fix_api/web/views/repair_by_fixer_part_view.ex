defmodule EasyFixApi.Web.RepairByFixerPartView do
  use EasyFixApi.Web, :view
  alias EasyFixApi.Web.RepairByFixerPartView

  def render("index.json", %{repair_by_fixer_parts: repair_by_fixer_parts}) do
    %{data: render_many(repair_by_fixer_parts, RepairByFixerPartView, "repair_by_fixer_part.json")}
  end

  def render("show.json", %{repair_by_fixer_part: repair_by_fixer_part}) do
    %{data: render_one(repair_by_fixer_part, RepairByFixerPartView, "repair_by_fixer_part.json")}
  end

  def render("repair_by_fixer_part.json", %{repair_by_fixer_part: repair_by_fixer_part}) do
    %{id: repair_by_fixer_part.id}
  end
end
