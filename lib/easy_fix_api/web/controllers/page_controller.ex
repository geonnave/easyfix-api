defmodule EasyFixApiWeb.PageController do
  use EasyFixApiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
