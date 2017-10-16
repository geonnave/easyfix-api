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

  def parts_call_direct(conn, _params) do
    parts_call_direct = Parts.list_parts() |> Parts.CallDirect.filter_parts_call_direct()
    render(conn, "parts_call_direct.json", parts_call_direct: parts_call_direct)
  end
end
