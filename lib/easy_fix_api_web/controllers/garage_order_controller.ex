defmodule EasyFixApiWeb.GarageOrderController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Orders

  action_fallback EasyFixApiWeb.FallbackController

  def list_orders(conn, _params = %{"garage_id" => garage_id}) do
    garage_orders = Orders.list_garage_order(garage_id)
    render(conn, "index.json", garage_orders: garage_orders)
  end

end
