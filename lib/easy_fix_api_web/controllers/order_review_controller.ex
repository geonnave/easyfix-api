defmodule EasyFixApiWeb.OrderReviewController do
  use EasyFixApiWeb, :controller
  alias EasyFixApi.{Orders, Parts, Repo}
  alias EasyFixApi.Orders.{Order, Matcher}

  def index(conn, _params) do
    orders = Orders.list_orders
    render conn, "index.html", orders: orders
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order!(id)
    garages = Matcher.list_garages_matching_order(order)
    render conn, "show.html", order: order, diag: order.diagnosis, customer: order.customer, garages: garages
  end
end
