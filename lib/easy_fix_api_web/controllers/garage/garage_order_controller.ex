defmodule EasyFixApiWeb.GarageOrderController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Orders}

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params = %{"garage_id" => garage_id}) do
    garage_orders =
      garage_id
      |> Orders.list_garage_orders()
      |> Enum.sort(& &1.order.inserted_at >= &2.order.inserted_at)

    render(conn, "index.json", garage_orders: garage_orders)
  end

  def show(conn, _params = %{"garage_id" => garage_id, "id" => order_id}) do
    garage_order = Orders.get_garage_order(garage_id, order_id)
    render(conn, "show.json", garage_order: garage_order)
  end
end
