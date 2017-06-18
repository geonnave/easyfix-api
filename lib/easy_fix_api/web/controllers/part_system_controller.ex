defmodule EasyFixApi.Web.PartSystemController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Parts
  alias EasyFixApi.Parts.PartSystem

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    part_systems = Parts.list_part_systems()
    render(conn, "index.json", part_systems: part_systems)
  end

  def create(conn, %{"part_system" => part_system_params}) do
    with {:ok, %PartSystem{} = part_system} <- Parts.create_part_system(part_system_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", part_system_path(conn, :show, part_system))
      |> render("show.json", part_system: part_system)
    end
  end

  def show(conn, %{"id" => id}) do
    part_system = Parts.get_part_system!(id)
    render(conn, "show.json", part_system: part_system)
  end

  def update(conn, %{"id" => id, "part_system" => part_system_params}) do
    part_system = Parts.get_part_system!(id)

    with {:ok, %PartSystem{} = part_system} <- Parts.update_part_system(part_system, part_system_params) do
      render(conn, "show.json", part_system: part_system)
    end
  end

  def delete(conn, %{"id" => id}) do
    part_system = Parts.get_part_system!(id)
    with {:ok, %PartSystem{}} <- Parts.delete_part_system(part_system) do
      send_resp(conn, :no_content, "")
    end
  end
end
