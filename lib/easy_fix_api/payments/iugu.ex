defmodule EasyFixApi.Payments.Iugu do
  use Tesla

  require Logger

  @api_key_header Base.encode64(Application.get_env(:easy_fix_api, :iugu)[:api_key] <> ":")
  @test? Application.get_env(:easy_fix_api, :iugu)[:test?]

  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.BaseUrl, Application.get_env(:easy_fix_api, :iugu)[:base_url]
  plug Tesla.Middleware.Headers, %{"Authorization" => "Basic #{@api_key_header}"}
  plug Tesla.Middleware.JSON

  def charge(pending_changeset, order) do
    pending_changeset
    |> build_payload(order)
    |> maybe_enable_test()
    |> charge_request()
  end

  def charge_request(payload) do
    payload = if @test? do
      put_in payload[:test], true
    else
      payload
    end

    with resp = %{status: 200} <- post("/charge", payload),
         body = %{"success" => true, "message" => "Autorizado"} <- resp.body do
      Logger.info "Payment authorized by Iugu, invoice id is #{body["invoice_id"]}"
      Logger.debug inspect(resp)
      {:ok, body["invoice_id"]}
    else
      resp = %{status: _, body: error} ->
        Logger.debug inspect(resp)
        Logger.debug inspect(error)
        {:error, error}
      error ->
        Logger.debug inspect(error)
        {:error, error}
    end
  end

  def maybe_enable_test(payload) do
    if @test? do
      put_in payload[:test], true
    else
      payload
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
          # TODO: add information about part names and service
          description: "Pedido \##{payload.order_id}, orçamento \##{payload.quote_id}",
          price_cents: payload.total_amount,
          quantity: 1
        }
      ],
      # TODO: use custom_variables if possible
      # custom_variables: [
      #   %{name: "garage_name", value: "EasyFix Personal"}
      # ],
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
