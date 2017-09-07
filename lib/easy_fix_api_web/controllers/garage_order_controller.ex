defmodule EasyFixApiWeb.GarageOrderController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Orders, Accounts}

  action_fallback EasyFixApiWeb.FallbackController

  def list_orders(conn, _params = %{"garage_id" => garage_id}) do
    garage_orders = Orders.list_garage_order(garage_id)
    render(conn, "index.json", garage_orders: garage_orders)
  end

  def create_budget(conn, params = %{"budget" => budget_params, "garage_id" => garage_id, "order_id" => order_id}) do
    garage = Accounts.get_garage!(garage_id)
    order = Orders.get_order!(order_id)
    {:ok, budget} = Orders.create_budget_for_garage(budget_params, garage, order)

    render(conn, EasyFixApiWeb.BudgetView, "show.json", budget: budget)
  end

end
