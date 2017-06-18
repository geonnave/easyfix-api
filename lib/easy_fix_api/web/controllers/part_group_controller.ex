defmodule EasyFixApi.Web.PartGroupController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Parts
  alias EasyFixApi.Parts.PartGroup

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    part_groups = Parts.list_part_groups()
    render(conn, "index.json", part_groups: part_groups)
  end

  def create(conn, %{"part_group" => part_group_params}) do
    with {:ok, %PartGroup{} = part_group} <- Parts.create_part_group(part_group_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", part_group_path(conn, :show, part_group))
      |> render("show.json", part_group: part_group)
    end
  end

  def show(conn, %{"id" => id}) do
    part_group = Parts.get_part_group!(id)
    render(conn, "show.json", part_group: part_group)
  end

  def update(conn, %{"id" => id, "part_group" => part_group_params}) do
    part_group = Parts.get_part_group!(id)

    with {:ok, %PartGroup{} = part_group} <- Parts.update_part_group(part_group, part_group_params) do
      render(conn, "show.json", part_group: part_group)
    end
  end

  def delete(conn, %{"id" => id}) do
    part_group = Parts.get_part_group!(id)
    with {:ok, %PartGroup{}} <- Parts.delete_part_group(part_group) do
      send_resp(conn, :no_content, "")
    end
  end
end
