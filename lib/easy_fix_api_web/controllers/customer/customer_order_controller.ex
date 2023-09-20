defmodule EasyFixApiWeb.CustomerOrderController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Orders, CustomerOrders, Emails, Mailer}
  alias EasyFixApi.Orders.OrderStateMachine

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params = %{"customer_id" => customer_id}) do
    customer_orders =
      customer_id
      |> CustomerOrders.list_orders()
      |> Enum.sort_by(fn order -> Timex.to_unix(order.inserted_at) end, &>=/2)

    render(conn, "index.json", customer_orders: customer_orders)
  end

  def show(conn, _params = %{"customer_id" => customer_id, "id" => order_id}) do
    case CustomerOrders.get_order(customer_id, order_id) do
      {:ok, customer_order} ->
        render(conn, "show.json", customer_order: customer_order)
      {:error, error} ->
        render(conn, EasyFixApiWeb.ErrorView, "error.json", error: error)
    end
  end

  def create(conn, %{"order" => order_params, "customer_id" => customer_id}) do
    {:ok, customer_order} =
      order_params
      |> put_in(["customer_id"], customer_id)
      |> Orders.create_order_with_diagnosis

    OrderStateMachine.start_link(%{order_id: customer_order.id})

    if customer_order.diagnosis.diagnosis_parts == [] do
      Emails.Customer.new_order_call_fixer(customer_order) |> Mailer.deliver_later
      Emails.Internal.new_order_call_fixer(customer_order) |> Mailer.deliver_later
      Emails.Customer.new_order_call_fixer(customer_order) |> Mailer.deliver_later
    else
      Emails.Garage.send_email_to_matching_garages(customer_order)
      Emails.Customer.new_order_call_direct(customer_order) |> Mailer.deliver_later
      Emails.Internal.new_order_call_direct(customer_order) |> Mailer.deliver_later
    end

    conn
    |> put_status(:created)
    |> put_resp_header("location", customer_order_path(conn, :show, customer_id, customer_order))
    |> render("show.json", customer_order: customer_order)
  end

  def update_state(conn, params = %{"event" => event_params}) do
    %{"customer_id" => customer_id, "order_id" => order_id} = params

    {:ok, order} = CustomerOrders.get_order(customer_id, order_id)

    event = event_params["name"] |> String.to_atom
    data_params = event_params["data"]
    with {:ok, updated_order} <- OrderStateMachine.customer_clicked(order.id, event, data_params) do
      render(conn, "show.json", customer_order: updated_order)
    end
  end

  def rate(conn, params = %{"rating" => rating_params}) do
    %{"customer_id" => customer_id, "order_id" => order_id} = params

    with {:ok, order} <- CustomerOrders.get_order(customer_id, order_id),
         :quote_accepted_by_customer <- order.state,
         {:ok, updated_order} <- Orders.set_order_rating(order, rating_params) do
      Emails.Internal.customer_rating(updated_order) |> Mailer.deliver_later

      conn
      |> put_status(:created)
      |> render("show.json", customer_order: updated_order)
    else
      err = {:error, _} ->
        err
      state ->
        {:error, "cannot set order rating at order state #{state}"}
    end
  end
end
