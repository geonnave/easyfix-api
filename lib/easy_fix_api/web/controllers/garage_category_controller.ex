defmodule EasyFixApi.Web.GarageCategoryController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Parts
  alias EasyFixApi.Parts.GarageCategory

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    garage_categories = Parts.list_garage_categories()
    render(conn, "index.json", garage_categories: garage_categories)
  end

  def create(conn, %{"garage_category" => garage_category_params}) do
    with {:ok, %GarageCategory{} = garage_category} <- Parts.create_garage_category(garage_category_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", garage_category_path(conn, :show, garage_category))
      |> render("show.json", garage_category: garage_category)
    end
  end

  def show(conn, %{"id" => id}) do
    garage_category = Parts.get_garage_category!(id)
    render(conn, "show.json", garage_category: garage_category)
  end

  def update(conn, %{"id" => id, "garage_category" => garage_category_params}) do
    garage_category = Parts.get_garage_category!(id)

    with {:ok, %GarageCategory{} = garage_category} <- Parts.update_garage_category(garage_category, garage_category_params) do
      render(conn, "show.json", garage_category: garage_category)
    end
  end

  def delete(conn, %{"id" => id}) do
    garage_category = Parts.get_garage_category!(id)
    with {:ok, %GarageCategory{}} <- Parts.delete_garage_category(garage_category) do
      send_resp(conn, :no_content, "")
    end
  end
end
