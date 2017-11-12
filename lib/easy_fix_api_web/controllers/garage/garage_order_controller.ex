defmodule EasyFixApiWeb.GarageOrderController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Orders, GarageOrders}

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params = %{"garage_id" => garage_id}) do
    garage_orders =
      garage_id
      |> GarageOrders.list_orders()
      |> Enum.sort_by(fn %{order: order} -> Timex.to_unix(order.inserted_at) end, &>=/2)

    render(conn, "index.json", garage_orders: garage_orders)
  end

  def show(conn, _params = %{"garage_id" => garage_id, "id" => order_id}) do
    garage_order = GarageOrders.get_order(garage_id, order_id)
    render(conn, "show.json", garage_order: garage_order)
  end
end
