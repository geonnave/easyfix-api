defmodule EasyFixApiWeb.OrderReviewController do
  use EasyFixApiWeb, :controller
  alias EasyFixApi.{Orders, Parts, Repo}
  alias EasyFixApi.Orders.Order

  def index(conn, _params) do
    orders = Orders.list_orders
    render conn, "index.html", orders: orders
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order!(id)
    render conn, "show.html", order: order, diag: order.diagnosis, customer: order.customer
  end
end
