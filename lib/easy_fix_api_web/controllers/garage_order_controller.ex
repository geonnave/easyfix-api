defmodule EasyFixApiWeb.GarageOrderController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Orders

  action_fallback EasyFixApiWeb.FallbackController

  def list_orders(conn, params = %{"garage_id" => garage_id}) do
    # garages = Accounts.list_garages()
    garage_orders = Orders.list_garage_order(garage_id)
    IO.inspect params
    render(conn, "index.json", garage_orders: garage_orders)
  end

end
