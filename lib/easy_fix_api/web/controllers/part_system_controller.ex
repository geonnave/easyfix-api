defmodule EasyFixApi.Web.PartSystemController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Parts

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    part_systems = Parts.list_part_systems()
    render(conn, "index.json", part_systems: part_systems)
  end

  def show(conn, %{"id" => id}) do
    part_system = Parts.get_part_system!(id)
    render(conn, "show.json", part_system: part_system)
  end
end
