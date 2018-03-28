defmodule EasyFixApiWeb.CustomerPaymentController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Payments, CustomerOrders, Vouchers}
  alias EasyFixApi.Orders.OrderStateMachine

  action_fallback EasyFixApiWeb.FallbackController
  plug Guardian.Plug.EnsureAuthenticated,
    [handler: EasyFixApiWeb.SessionController] when not action in [:create]

  def index(conn, _params = %{"customer_id" => customer_id}) do
    payments = Payments.list_payments(String.to_integer(customer_id))
    render(conn, "index.json", customer_payments: payments)
  end

  def show(conn, %{"id" => id}) do
    payment = Payments.get_payment!(id)
    render(conn, "show.json", customer_payment: payment)
  end

  def create(conn, %{"payment" => payment_params = %{"order_id" => order_id}, "customer_id" => customer_id}) do
    # FIXME: adjust this to *properly* use the OrderStateMachine

    customer_id = String.to_integer(customer_id)
    with {:ok, order} <- CustomerOrders.get_order(customer_id, order_id),
         :ok <- check_state(order),
         {:ok, payment} <- Payments.create_payment(payment_params, customer_id),
         attrs = %{accepted_quote_id: payment.quote_id},
         {:ok, _updated_order} <- OrderStateMachine.customer_clicked(order.id, :accept_quote, attrs) do

      if applied_voucher_code = payment_params["applied_voucher_code"] do
        Vouchers.use_voucher(payment_params["applied_voucher_id"])
        Vouchers.reward_voucher(applied_voucher_code)
      end

      conn
      |> put_status(:created)
      |> render("show.json", customer_payment: payment)
    end
  end

  def check_state(%{state: state}) do
    if state in [:created_with_diagnosis, :quoted_by_garages] do
      :ok
    else
      {:error, "invalid state #{inspect state}"}
    end
  end
end
