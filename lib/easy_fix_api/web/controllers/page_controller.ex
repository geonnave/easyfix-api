defmodule EasyFixApi.Web.PageController do
  use EasyFixApi.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
