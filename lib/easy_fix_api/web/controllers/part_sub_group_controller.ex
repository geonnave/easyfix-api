defmodule EasyFixApi.Web.PartSubGroupController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Parts

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    part_sub_groups = Parts.list_part_sub_groups()
    render(conn, "index.json", part_sub_groups: part_sub_groups)
  end

  def show(conn, %{"id" => id}) do
    part_sub_group = Parts.get_part_sub_group!(id)
    render(conn, "show.json", part_sub_group: part_sub_group)
  end
end
