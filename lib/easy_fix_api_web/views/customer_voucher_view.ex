defmodule EasyFixApiWeb.CustomerVoucherView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.{CustomerVoucherView, DateView}

  def render("index.json", %{customer_vouchers: customer_vouchers}) do
    %{data: render_many(customer_vouchers, CustomerVoucherView, "customer_voucher.json")}
  end

  def render("show.json", %{customer_voucher: customer_voucher}) do
    %{data: render_one(customer_voucher, CustomerVoucherView, "customer_voucher.json")}
  end

  def render("customer_voucher.json", %{customer_voucher: customer_voucher}) do
    %{
      id: customer_voucher.id,
      code: customer_voucher.code,
      date_used: DateView.render("iso_at_sao_paulo_tz", customer_voucher.date_used),
      inserted_at: DateView.render("iso_at_sao_paulo_tz", customer_voucher.inserted_at),
      type: customer_voucher.type,
      discount: 30.0
    }
  end
end
