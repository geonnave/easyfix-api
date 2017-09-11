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
      state: order.state,
      state_due_date: order.state_due_date,
      conclusion_date: order.conclusion_date,
      customer_id: order.customer.id,
      diagnosis: render_one(order.diagnosis, EasyFixApiWeb.DiagnosisView, "diagnosis.json"),
      # budget: render_one(budget, EasyFixApiWeb.BudgetView, "budget.json")
    }
  end
end
