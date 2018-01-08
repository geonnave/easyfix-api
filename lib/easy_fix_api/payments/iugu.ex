defmodule EasyFixApi.Iugu do
  use Tesla

  require Logger
  alias EasyFixApi.Parts

  @api_key_header Base.encode64(Application.get_env(:easy_fix_api, :iugu_api_key) <> ":")

  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.BaseUrl, "https://api.iugu.com/v1"
  plug Tesla.Middleware.Headers, %{"Authorization" => "Basic #{@api_key_header}"}
  plug Tesla.Middleware.JSON

  def charge(pending_changeset, order) do
    payload = build_payload(pending_changeset, order)
    {:ok, %{}}
    # with resp = %{status: 200} <- post("/charge", payload),
    #      body = %{"sucess" => true, "message" => "Autorizado"} <- resp.body do
    #   {:ok, body}
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
      items: Enum.map(payload.payment_parts, fn payment_part ->
        part = Parts.get_part!(payment_part.part_id)
        %{description: part.name, price_cents: payment_part.price, quantity: payment_part.quantity}
      end)
    } |> IO.inspect
  end

end

defmodule EasyFixApi.MockIugu do
  require Logger

  def charge(pending_changeset, order) do
    Logger.debug "Pretending to charge: #{inspect {order.id, pending_changeset}}"
  end
end
