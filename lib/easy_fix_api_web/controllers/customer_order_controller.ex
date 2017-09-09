defmodule EasyFixApiWeb.CustomerOrderController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Orders}

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, params = %{"customer_id" => customer_id}) do
    IO.inspect params
    customer_orders = Orders.list_customer_orders(customer_id)
    render(conn, "index.json", customer_orders: customer_orders)
  end

  def show(conn, _params = %{"customer_id" => customer_id, "id" => order_id}) do
    case Orders.get_customer_order(customer_id, order_id) do
      {:ok, customer_order} ->
        render(conn, "show.json", customer_order: customer_order)
      {:error, error} ->
        render(conn, EasyFixApiWeb.ErrorView, "error.json", error: error)
    end
  end

  # def create(conn, %{"order" => order_params, "customer_id" => customer_id}) do
  #   {:ok, order} =
  #     order_params
  #     |> put_in([:customer_id], customer_id)
  #     |> Orders.create_order_with_diagnosis

  #   conn
  #   |> put_status(:created)
  #   |> put_resp_header("location", order_path(conn, :show, order))
  #   |> render("show.json", order: order)
  # end
end
