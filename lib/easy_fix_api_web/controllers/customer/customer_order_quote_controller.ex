defmodule EasyFixApiWeb.CustomerOrderQuoteController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Orders}

  action_fallback EasyFixApiWeb.FallbackController

  def best_quote(conn, _params = %{"customer_id" => customer_id, "order_id" => order_id}) do
    with {:ok, customer_order_quotes} <- Orders.get_customer_order_quotes(customer_id, order_id) do
      render(conn, "show.json", customer_order_quotes: customer_order_quotes)
    end
  end
end
