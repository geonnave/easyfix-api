defmodule EasyFixApiWeb.CustomerEmailController do
  use EasyFixApiWeb, :controller
  alias EasyFixApi.{CustomerOrders, Emails, Mailer}

  action_fallback EasyFixApiWeb.FallbackController

  def create(conn, %{"customer_id" => customer_id, "order_id" => order_id, "message" => message}) do
    {:ok, order} = CustomerOrders.get_order(customer_id, order_id)

    message = Emails.Internal.customer_message(order, message)
    Mailer.deliver_later(message)

    conn
    |> put_status(201)
    |> json(%{data: message})
  end
end
