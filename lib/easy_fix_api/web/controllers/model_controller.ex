defmodule EasyFixApi.Web.ModelController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.StaticData
  alias EasyFixApi.StaticData.Model

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    models = StaticData.list_models()
    render(conn, "index.json", models: models)
  end

  def create(conn, %{"model" => model_params}) do
    with {:ok, %Model{} = model} <- StaticData.create_model(model_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", model_path(conn, :show, model))
      |> render("show.json", model: model)
    end
  end

  def show(conn, %{"id" => id}) do
    model = StaticData.get_model!(id)
    render(conn, "show.json", model: model)
  end

  def update(conn, %{"id" => id, "model" => model_params}) do
    model = StaticData.get_model!(id)

    with {:ok, %Model{} = model} <- StaticData.update_model(model, model_params) do
      render(conn, "show.json", model: model)
    end
  end

  def delete(conn, %{"id" => id}) do
    model = StaticData.get_model!(id)
    with {:ok, %Model{}} <- StaticData.delete_model(model) do
      send_resp(conn, :no_content, "")
    end
  end
end
