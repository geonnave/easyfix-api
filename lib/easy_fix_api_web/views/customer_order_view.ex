defmodule EasyFixApiWeb.CustomerOrderView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.CustomerOrderView

  def render("index.json", %{customer_orders: customer_orders}) do
    %{data: render_many(customer_orders, CustomerOrderView, "customer_order.json")}
  end

  def render("show.json", %{customer_order: customer_order}) do
    %{data: render_one(customer_order, CustomerOrderView, "customer_order.json")}
  end

  def render("customer_order.json", %{customer_order: customer_order}) do
    order = customer_order#.order
    # budget = customer_order.budget
    %{id: order.id,
      status: order.status,
      sub_status: order.sub_status,
      opening_date: order.opening_date,
      conclusion_date: order.conclusion_date,
      customer_id: order.customer.id,
      diagnosis: render_one(order.diagnosis, EasyFixApiWeb.DiagnosisView, "diagnosis.json"),
      # budget: render_one(budget, EasyFixApiWeb.BudgetView, "budget.json")
    }
  end
end
