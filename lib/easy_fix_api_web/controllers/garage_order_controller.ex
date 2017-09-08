defmodule EasyFixApiWeb.GarageOrderController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Orders, Accounts}

  action_fallback EasyFixApiWeb.FallbackController

  def list_orders(conn, _params = %{"garage_id" => garage_id}) do
    garage_orders = Orders.list_garage_order(garage_id)
    render(conn, "index.json", garage_orders: garage_orders)
  end

  def show_order(conn, _params = %{"garage_id" => garage_id, "order_id" => order_id}) do
    garage_order = Orders.get_garage_order(garage_id, order_id)
    render(conn, "index.json", garage_order: garage_order)
  end

  def create_budget(conn, params = %{"budget" => budget_params, "garage_id" => garage_id, "order_id" => order_id}) do
    order = Orders.get_order!(order_id)

    {:ok, budget} =
      budget_params
      |> put_in(["diagnosis_id"], order.diagnosis_id)
      |> put_in(["issuer_id"], garage_id)
      |> put_in(["issuer_type"], "garage")
      |> Orders.create_budget()

    render(conn, EasyFixApiWeb.BudgetView, "show.json", budget: budget)
  end

end
