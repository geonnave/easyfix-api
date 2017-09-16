defmodule EasyFixApiWeb.BudgetPartView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.BudgetPartView

  def render("index.json", %{budget_parts: budget_parts}) do
    %{data: render_many(budget_parts, BudgetPartView, "budget_part.json")}
  end

  def render("show.json", %{budget_part: budget_part}) do
    %{data: render_one(budget_part, BudgetPartView, "budget_part.json")}
  end

  def render("budget_part.json", %{budget_part: budget_part}) do
    %{id: budget_part.id,
      quantity: budget_part.quantity,
      price: budget_part.price,
      part: render_one(budget_part.part, EasyFixApiWeb.PartView, "part.json"),
    }
  end
end
