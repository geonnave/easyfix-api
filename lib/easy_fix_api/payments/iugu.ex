defmodule EasyFixApi.Iugu do
  use Tesla

  require Logger
  alias EasyFixApi.Parts

  @api_key_header Base.encode64(Application.get_env(:easy_fix_api, :iugu)[:api_key] <> ":")

  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.BaseUrl, Application.get_env(:easy_fix_api, :iugu)[:base_url]
  plug Tesla.Middleware.Headers, %{"Authorization" => "Basic #{@api_key_header}"}
  plug Tesla.Middleware.JSON

  def charge(pending_changeset, order) do
    payload = build_payload(pending_changeset, order)

    # XXX: do this to avoid charging wrong values while developing
    payload = %{payload | items: [%{description: "test", price_cents: 100, quantity: 1}]}

    {:ok, "123"}
    # with resp = %{status: 200} <- post("/charge", payload),
    #      body = %{"sucess" => true, "message" => "Autorizado"} <- resp.body do
    #   {:ok, body["invoice_id"]}
    # else
    #   error ->
    #     Logger.debug error
    #     {:error, error}
    # end
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

defmodule EasyFixApi.MockIugu do
  require Logger

  def charge(pending_changeset, order) do
    Logger.debug "Pretending to charge: #{inspect {order.id, pending_changeset}}"
    {:ok, "123"}
  end
end
