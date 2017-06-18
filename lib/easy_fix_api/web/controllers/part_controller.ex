defmodule EasyFixApi.Web.PartController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Parts
  alias EasyFixApi.Parts.Part

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    parts = Parts.list_parts()
    render(conn, "index.json", parts: parts)
  end

  def create(conn, %{"part" => part_params}) do
    with {:ok, %Part{} = part} <- Parts.create_part(part_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", part_path(conn, :show, part))
      |> render("show.json", part: part)
    end
  end

  def show(conn, %{"id" => id}) do
    part = Parts.get_part!(id)
    render(conn, "show.json", part: part)
  end

  def update(conn, %{"id" => id, "part" => part_params}) do
    part = Parts.get_part!(id)

    with {:ok, %Part{} = part} <- Parts.update_part(part, part_params) do
      render(conn, "show.json", part: part)
    end
  end

  def delete(conn, %{"id" => id}) do
    part = Parts.get_part!(id)
    with {:ok, %Part{}} <- Parts.delete_part(part) do
      send_resp(conn, :no_content, "")
    end
  end
end
