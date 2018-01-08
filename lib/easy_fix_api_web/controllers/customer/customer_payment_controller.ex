defmodule EasyFixApiWeb.CustomerPaymentController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Payments}

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params = %{"customer_id" => customer_id}) do
    payments = Payments.list_payments(customer_id)
    render(conn, "index.json", payments: payments)
  end

  def create(conn, %{"payment" => payment_params, "customer_id" => customer_id}) do
    with {:ok, _payment} <- Payments.create_payment(payment_params, String.to_integer(customer_id)) do
      render(conn, "show.json", customer_payment: %{})
    else
      payment_changeset = %{valid?: false} ->
        {:error, payment_changeset}
      {:error, invoice} ->
        {:error, invoice}
    end
  end
end
