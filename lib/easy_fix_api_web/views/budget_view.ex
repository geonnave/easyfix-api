defmodule EasyFixApiWeb.BudgetView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.{BudgetView, DateView}

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
      opening_date: DateView.render("iso_at_sao_paulo_tz", budget.opening_date),
      due_date: DateView.render("iso_at_sao_paulo_tz", budget.due_date),
      conclusion_date: DateView.render("iso_at_sao_paulo_tz", budget.conclusion_date),
      # parts: render_many(budget.parts, EasyFixApiWeb.PartView, "part.json"),
      parts: render_many(budget.budgets_parts, EasyFixApiWeb.BudgetPartView, "budget_part.json"),
      diagnosis_id: budget.diagnosis_id,
      issuer_type: budget.issuer_type,
      issuer_id: Map.get(budget.issuer, budget.issuer_type).id,
    }
  end
end
