defmodule EasyFixApiWeb.BudgetView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.BudgetView

  def render("index.json", %{budgets: budgets}) do
    %{data: render_many(budgets, BudgetView, "budget.json")}
  end

  def render("show.json", %{budget: budget}) do
    %{data: render_one(budget, BudgetView, "budget.json")}
  end

  def render("budget.json", %{budget: budget}) do
    %{id: budget.id,
      service_cost: budget.service_cost,
      due_date: budget.due_date,
      parts: render_many(budget.parts, EasyFixApiWeb.BudgetPartView, "budget_part.json"),
      diagnostic_id: budget.diagnostic.id,
    }
  end
end
