defmodule EasyFixApiWeb.GarageOrderBudgetController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Orders}

  action_fallback EasyFixApiWeb.FallbackController

  def create(conn, _params = %{"budget" => budget_params, "garage_id" => garage_id, "order_id" => order_id}) do
    order = Orders.get_order!(order_id)

    {:ok, budget} =
      budget_params
      |> put_in(["diagnosis_id"], order.diagnosis.id)
      |> put_in(["issuer_id"], garage_id)
      |> put_in(["issuer_type"], "garage")
      |> Orders.create_budget()

    render(conn, EasyFixApiWeb.BudgetView, "show.json", budget: budget)
  end

  def show(conn, %{"garage_id" => garage_id, "order_id" => order_id}) do
    with {:ok, budget} <- Orders.get_budget_for_garage_order(garage_id, order_id) do
      render(conn, EasyFixApiWeb.BudgetView, "show.json", budget: budget)
    else
      {:error, error} ->
        render(conn, EasyFixApiWeb.ErrorView, "error.json", error: error)
    end
  end

  def update(conn, %{"budget" => budget_params, "garage_id" => garage_id, "order_id" => order_id}) do
    %{order: _order, budget: budget} = Orders.get_garage_order(garage_id, order_id)

    with {:ok, budget} <- Orders.update_budget(budget, budget_params) do
      render(conn, EasyFixApiWeb.BudgetView, "show.json", budget: budget)
    end
  end
end
