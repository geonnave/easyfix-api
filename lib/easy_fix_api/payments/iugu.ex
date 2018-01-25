defmodule EasyFixApi.Payments.Iugu do
  use Tesla

  require Logger

  @api_key_header Base.encode64(Application.get_env(:easy_fix_api, :iugu)[:api_key] <> ":")

  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.BaseUrl, Application.get_env(:easy_fix_api, :iugu)[:base_url]
  plug Tesla.Middleware.Headers, %{"Authorization" => "Basic #{@api_key_header}"}
  plug Tesla.Middleware.JSON

  def charge(pending_changeset, order) do
    payload = build_payload(pending_changeset, order)

    charge_request(payload)
  end

  def charge_request(payload) do
    payload = put_in payload[:test], true

    with resp = %{status: 200} <- post("/charge", payload),
         body = %{"success" => true, "message" => "Autorizado"} <- resp.body do
      {:ok, body["invoice_id"]}
    else
      %{status: _, body: error} ->
        Logger.debug inspect(error)
        {:error, error}
      error ->
        Logger.debug inspect(error)
        {:error, error}
    end
  end

  def build_payload(changeset, order) do
    payload = Ecto.Changeset.apply_changes(changeset)
    %{
      token: payload.token,
      email: order.customer.user.email,
      months: payload.installments,
      items: [
        %{
          description: "Pedido \##{payload.order_id}, orçamento \##{payload.quote_id}",
          price_cents: payload.amount,
          quantity: 1
        }
      ]
    } |> IO.inspect
  end

end

defmodule EasyFixApi.Payments.MockIugu do
  require Logger

  def charge(pending_changeset, order) do
    Logger.debug "Pretending to charge: #{inspect {order.id, pending_changeset}}"
    {:ok, "123"}
  end
end
