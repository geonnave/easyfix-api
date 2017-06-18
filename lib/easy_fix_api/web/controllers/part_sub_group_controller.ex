defmodule EasyFixApi.Web.PartSubGroupController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Parts
  alias EasyFixApi.Parts.PartSubGroup

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    part_sub_groups = Parts.list_part_sub_groups()
    render(conn, "index.json", part_sub_groups: part_sub_groups)
  end

  def create(conn, %{"part_sub_group" => part_sub_group_params}) do
    with {:ok, %PartSubGroup{} = part_sub_group} <- Parts.create_part_sub_group(part_sub_group_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", part_sub_group_path(conn, :show, part_sub_group))
      |> render("show.json", part_sub_group: part_sub_group)
    end
  end

  def show(conn, %{"id" => id}) do
    part_sub_group = Parts.get_part_sub_group!(id)
    render(conn, "show.json", part_sub_group: part_sub_group)
  end

  def update(conn, %{"id" => id, "part_sub_group" => part_sub_group_params}) do
    part_sub_group = Parts.get_part_sub_group!(id)

    with {:ok, %PartSubGroup{} = part_sub_group} <- Parts.update_part_sub_group(part_sub_group, part_sub_group_params) do
      render(conn, "show.json", part_sub_group: part_sub_group)
    end
  end

  def delete(conn, %{"id" => id}) do
    part_sub_group = Parts.get_part_sub_group!(id)
    with {:ok, %PartSubGroup{}} <- Parts.delete_part_sub_group(part_sub_group) do
      send_resp(conn, :no_content, "")
    end
  end
end
