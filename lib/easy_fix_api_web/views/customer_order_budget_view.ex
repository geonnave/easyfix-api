defmodule EasyFixApiWeb.CustomerOrderBudgetView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.CustomerOrderBudgetView

  def render("best_budget.json", %{customer_best_budget: customer_best_budget}) do
    %{data: render_one(customer_best_budget, EasyFixApiWeb.BudgetView, "budget.json")}
  end
end
