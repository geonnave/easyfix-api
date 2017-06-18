defmodule EasyFixApi.Web.GarageCategoryView do
  use EasyFixApi.Web, :view
  alias EasyFixApi.Web.GarageCategoryView

  def render("index.json", %{garage_categories: garage_categories}) do
    %{data: render_many(garage_categories, GarageCategoryView, "garage_category.json")}
  end

  def render("show.json", %{garage_category: garage_category}) do
    %{data: render_one(garage_category, GarageCategoryView, "garage_category.json")}
  end

  def render("garage_category.json", %{garage_category: garage_category}) do
    %{id: garage_category.id,
      name: garage_category.name}
  end
end
