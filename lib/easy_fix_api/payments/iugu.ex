defmodule EasyFixApi.Iugu do
  use Tesla

  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.BaseUrl, "https://api.iugu.com/v1"
  plug Tesla.Middleware.Headers, %{"Authorization" => "Basic QVBJX1RPS0VOOg=="}
  plug Tesla.Middleware.JSON

  def charge(pending_changeset, order) do
    payment = pending_changeset.changes
    items = [
      %{
        description: "banco diagonal",
        quantity: 1,
        price: 10_00,
      }
    ]
    payload = %{
      token: payment.token,
      email: order.customer.user.email,
      months: payment.installments,
      # discount_cents: payment.discounts,
      items: items
    }
    # post("/charge", payload)
    {:ok, %{}}
  end

end

defmodule EasyFixApi.MockIugu do
  require Logger

  def charge(pending_changeset, order) do
    Logger.debug "Pretending to charge: #{inspect {order.id, pending_changeset}}"
  end
end
