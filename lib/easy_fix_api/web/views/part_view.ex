defmodule EasyFixApi.Web.PartView do
  use EasyFixApi.Web, :view
  alias EasyFixApi.Web.PartView

  def render("index.json", %{parts: parts}) do
    %{data: render_many(parts, PartView, "part.json")}
  end

  def render("show.json", %{part: part}) do
    %{data: render_one(part, PartView, "part.json")}
  end

  def render("part.json", %{part: part}) do
    %{id: part.id,
      name: part.name}
  end
end
