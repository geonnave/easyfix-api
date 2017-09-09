defmodule EasyFixApiWeb.BankController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Payments

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params) do
    banks = Payments.list_banks()
    render(conn, "index.json", banks: banks)
  end
end
