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
      status: budget.status,
      sub_status: budget.sub_status,
      opening_date: budget.opening_date,
      due_date: budget.due_date,
      conclusion_date: budget.conclusion_date,
      parts: render_many(budget.parts, EasyFixApiWeb.BudgetPartView, "budget_part.json"),
      diagnostic_id: budget.diagnostic.id,
      issuer_type: budget.issuer_type,
      issuer_id: Map.get(budget.issuer, budget.issuer_type).id,
    }
  end
end
