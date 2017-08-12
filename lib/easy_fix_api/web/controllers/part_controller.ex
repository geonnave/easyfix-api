defmodule EasyFixApiWeb.PartController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Parts

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params) do
    parts = Parts.list_parts()
    render(conn, "index.json", parts: parts)
  end

  def show(conn, %{"id" => id}) do
    part = Parts.get_part!(id)
    render(conn, "show.json", part: part)
  end
end
