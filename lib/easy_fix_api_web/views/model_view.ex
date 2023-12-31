defmodule EasyFixApiWeb.ModelView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.ModelView

  def render("index.json", %{models: models}) do
    %{data: render_many(models, ModelView, "model.json")}
  end

  def render("show.json", %{model: model}) do
    %{data: render_one(model, ModelView, "model.json")}
  end

  def render("model.json", %{model: model}) do
    %{id: model.id,
      name: model.name,
      brand: model.brand.name}
  end
end
