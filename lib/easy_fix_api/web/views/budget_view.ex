defmodule EasyFixApi.Web.BudgetView do
  use EasyFixApi.Web, :view
  alias EasyFixApi.Web.BudgetView

  def render("index.json", %{budgets: budgets}) do
    %{data: render_many(budgets, BudgetView, "budget.json")}
  end

  def render("show.json", %{budget: budget}) do
    %{data: render_one(budget, BudgetView, "budget.json")}
  end

  def render("budget.json", %{budget: budget}) do
    %{id: budget.id,
      service_cost: budget.service_cost,
      due_date: budget.due_date}
  end
end
