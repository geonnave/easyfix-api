defmodule EasyFixApiWeb.GarageOrderView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.GarageOrderView

  def render("index.json", %{garage_orders: garage_orders}) do
    %{data: render_many(garage_orders, GarageOrderView, "garage_order.json")}
  end

  def render("show.json", %{garage_order: garage_order}) do
    %{data: render_one(garage_order, GarageOrderView, "garage_order.json")}
  end

  def render("garage_order.json", %{garage_order: garage_order}) do
    order = garage_order.order
    budget = garage_order.budget
    %{id: order.id,
      status: order.status,
      sub_status: order.sub_status,
      opening_date: order.opening_date,
      conclusion_date: order.conclusion_date,
      customer_id: order.customer.id,
      diagnosis: render_one(order.diagnosis, EasyFixApiWeb.DiagnosisView, "diagnosis.json"),
      budget: render_one(budget, EasyFixApiWeb.BudgetView, "budget.json")
    }
  end
end
