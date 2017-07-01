defmodule EasyFixApi.Web.GarageCategoryController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Parts

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    garage_categories = Parts.list_garage_categories()
    render(conn, "index.json", garage_categories: garage_categories)
  end

  def show(conn, %{"id" => id}) do
    garage_category = Parts.get_garage_category!(id)
    render(conn, "show.json", garage_category: garage_category)
  end
end
