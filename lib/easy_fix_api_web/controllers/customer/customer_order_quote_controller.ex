defmodule EasyFixApiWeb.CustomerOrderQuoteController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Orders}

  action_fallback EasyFixApiWeb.FallbackController

  def best_quote(conn, _params = %{"customer_id" => customer_id, "order_id" => order_id}) do
    with {:ok, customer_best_quote} <- Orders.get_customer_best_quote(customer_id, order_id) do
      render(conn, "best_quote.json", customer_best_quote: customer_best_quote)
    else
      {:error, error} ->
        render(conn, EasyFixApiWeb.ErrorView, "error.json", error: error)
    end
  end
end
