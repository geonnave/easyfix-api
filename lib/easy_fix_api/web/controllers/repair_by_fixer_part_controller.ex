defmodule EasyFixApi.Web.RepairByFixerPartController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Business

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    repair_by_fixer_parts = Business.list_repair_by_fixer_parts()
    render(conn, "index.json", repair_by_fixer_parts: repair_by_fixer_parts)
  end

  def show(conn, %{"id" => id}) do
    repair_by_fixer_part = Business.get_repair_by_fixer_part!(id)
    render(conn, "show.json", repair_by_fixer_part: repair_by_fixer_part)
  end
end
