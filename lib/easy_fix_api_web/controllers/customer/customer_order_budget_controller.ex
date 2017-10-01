defmodule EasyFixApiWeb.CustomerOrderBudgetController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Orders}

  action_fallback EasyFixApiWeb.FallbackController

  def best_budget(conn, _params = %{"customer_id" => customer_id, "order_id" => order_id}) do
    with {:ok, customer_best_budget} <- Orders.get_customer_best_budget(customer_id, order_id) do
      render(conn, "best_budget.json", customer_best_budget: customer_best_budget)
    else
      {:error, error} ->
        render(conn, EasyFixApiWeb.ErrorView, "error.json", error: error)
    end
  end
end
