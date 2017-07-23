defmodule EasyFixApi.Web.BankController do
  use EasyFixApi.Web, :controller

  alias EasyFixApi.Payments

  action_fallback EasyFixApi.Web.FallbackController

  def index(conn, _params) do
    banks = Payments.list_banks()
    render(conn, "index.json", banks: banks)
  end
end
