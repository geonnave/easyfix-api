defmodule EasyFixApiWeb.CustomerOrderQuoteController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{CustomerOrders}

  action_fallback EasyFixApiWeb.FallbackController

  def best_quote(conn, _params = %{"customer_id" => customer_id, "order_id" => order_id}) do
    with {:ok, customer_order_quotes} <- CustomerOrders.get_order_quotes(customer_id, order_id) do
      render(conn, "show.json", customer_order_quotes: customer_order_quotes)
    end
  end
end
