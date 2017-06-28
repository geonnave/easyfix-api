defmodule EasyFixApi.Web.ModelController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Cars

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    models = Cars.list_models()
    render(conn, "index.json", models: models)
  end
end
