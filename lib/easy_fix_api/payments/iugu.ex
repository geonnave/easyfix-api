defmodule EasyFixApi.Iugu do
  use Tesla

  require Logger

  @api_key_header Base.encode64(Application.get_env(:easy_fix_api, :iugu_api_key) <> ":")

  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.BaseUrl, "https://api.iugu.com/v1"
  plug Tesla.Middleware.Headers, %{"Authorization" => "Basic #{@api_key_header}"}
  plug Tesla.Middleware.JSON

  def charge(pending_changeset, order) do
    payment = pending_changeset.changes
    payload = %{
      token: payment.token,
      email: order.customer.user.email,
      months: payment.installments,
      items: payment.parts
    }

    with resp = %{status: 200} <- post("/charge", payload),
         body = %{"sucess" => true, "message" => "Autorizado"} <- resp.body do
      {:ok, body}
    else
      error ->
        Logger.debug error
        {:error, error}
    end
  end

end

defmodule EasyFixApi.MockIugu do
  require Logger

  def charge(pending_changeset, order) do
    Logger.debug "Pretending to charge: #{inspect {order.id, pending_changeset}}"
  end
end
