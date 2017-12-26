defmodule EasyFixApi.Iugu do
  use Tesla

  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.BaseUrl, "https://api.iugu.com/v1"
  plug Tesla.Middleware.Headers, %{"api_token" => "..."}
  plug Tesla.Middleware.JSON

  def charge(pending_changeset, order) do
    params = pending_changeset.changes
    %{
      token: params.token,
      email: order.customer.user.email,
      months: params.installments,
      # discount_dents: params.discounts,
      items: [
        %{}
      ]
    }
    # post("/charge", %{})
    {:ok, %{}}
  end

end

defmodule EasyFixApi.MockIugu do
  require Logger

  def charge(pending_changeset, order) do
    Logger.debug "Pretending to charge: #{inspect {order.id, pending_changeset}}"
  end
end
