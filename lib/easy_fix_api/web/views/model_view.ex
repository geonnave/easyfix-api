defmodule EasyFixApi.Web.ModelView do
  use EasyFixApi.Web, :view
  alias EasyFixApi.Web.ModelView

  def render("index.json", %{models: models}) do
    %{data: render_many(models, ModelView, "model.json")}
  end

  def render("show.json", %{model: model}) do
    %{data: render_one(model, ModelView, "model.json")}
  end

  def render("model.json", %{model: model}) do
    %{id: model.id,
      name: model.name}
  end
end
