defmodule EasyFixApi.Web.PartGroupController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Parts

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    part_groups = Parts.list_part_groups()
    render(conn, "index.json", part_groups: part_groups)
  end

  def show(conn, %{"id" => id}) do
    part_group = Parts.get_part_group!(id)
    render(conn, "show.json", part_group: part_group)
  end
end
