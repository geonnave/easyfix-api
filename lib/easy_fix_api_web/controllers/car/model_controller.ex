defmodule EasyFixApiWeb.ModelController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Cars

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params) do
    models = Cars.list_models()
    render(conn, "index.json", models: models)
  end

  def show(conn, %{"id" => id}) do
    model = Cars.get_model!(id)
    render(conn, "show.json", model: model)
  end
end
