defmodule EasyFixApiWeb.BudgetPartView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.BudgetPartView

  def render("index.json", %{budget_parts: budget_parts}) do
    %{data: render_many(budget_parts, Budget_partPartView, "budget_part.json")}
  end

  def render("show.json", %{budget_part: budget_part}) do
    %{data: render_one(budget_part, Budget_partPartView, "budget_part.json")}
  end

  def render("budget_part.json", %{budget_part: budget_part}) do
    %{part_id: budget_part.part.id,
      part_name: budget_part.part.name,
      price: budget_part.price,
      quantity: budget_part.quantity,
    }
  end
end
