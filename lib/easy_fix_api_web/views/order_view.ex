defmodule EasyFixApiWeb.OrderView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.OrderView

  def render("index.json", %{orders: orders}) do
    %{data: render_many(orders, OrderView, "order.json")}
  end

  def render("show.json", %{order: order}) do
    %{data: render_one(order, OrderView, "order.json")}
  end

  def render("order.json", %{order: order}) do
    %{id: order.id,
      status: order.status,
      sub_status: order.sub_status,
      opening_date: order.opening_date,
      conclusion_date: order.conclusion_date}
  end
end
