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
      state: order.state,
      state_due_date: order.state_due_date,
      inserted_at: order.inserted_at,
      conclusion_date: order.conclusion_date,
      diagnosis: render_one(order.diagnosis, EasyFixApiWeb.DiagnosisView, "diagnosis.json"),
      customer_id: order.customer.id,
    }
  end
end
