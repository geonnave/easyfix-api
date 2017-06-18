defmodule EasyFixApi.Web.RepairByFixerPartController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Business
  alias EasyFixApi.Business.RepairByFixerPart

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    repair_by_fixer_parts = Business.list_repair_by_fixer_parts()
    render(conn, "index.json", repair_by_fixer_parts: repair_by_fixer_parts)
  end

  def create(conn, %{"repair_by_fixer_part" => repair_by_fixer_part_params}) do
    with {:ok, %RepairByFixerPart{} = repair_by_fixer_part} <- Business.create_repair_by_fixer_part(repair_by_fixer_part_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", repair_by_fixer_part_path(conn, :show, repair_by_fixer_part))
      |> render("show.json", repair_by_fixer_part: repair_by_fixer_part)
    end
  end

  def show(conn, %{"id" => id}) do
    repair_by_fixer_part = Business.get_repair_by_fixer_part!(id)
    render(conn, "show.json", repair_by_fixer_part: repair_by_fixer_part)
  end

  def update(conn, %{"id" => id, "repair_by_fixer_part" => repair_by_fixer_part_params}) do
    repair_by_fixer_part = Business.get_repair_by_fixer_part!(id)

    with {:ok, %RepairByFixerPart{} = repair_by_fixer_part} <- Business.update_repair_by_fixer_part(repair_by_fixer_part, repair_by_fixer_part_params) do
      render(conn, "show.json", repair_by_fixer_part: repair_by_fixer_part)
    end
  end

  def delete(conn, %{"id" => id}) do
    repair_by_fixer_part = Business.get_repair_by_fixer_part!(id)
    with {:ok, %RepairByFixerPart{}} <- Business.delete_repair_by_fixer_part(repair_by_fixer_part) do
      send_resp(conn, :no_content, "")
    end
  end
end
