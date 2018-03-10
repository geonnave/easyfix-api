defmodule EasyFixApiWeb.CustomerVoucherController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Vouchers}

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params = %{"customer_id" => customer_id}) do
    vouchers = Vouchers.list_available_indication_codes(String.to_integer(customer_id))
    render(conn, "index.json", customer_vouchers: vouchers)
  end
end
