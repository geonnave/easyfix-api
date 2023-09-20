defmodule EasyFixApiWeb.CustomerPaymentView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.{CustomerPaymentView}

  def render("index.json", %{customer_payments: customer_payments}) do
    %{data: render_many(customer_payments, CustomerPaymentView, "customer_payment.json")}
  end

  def render("show.json", %{customer_payment: customer_payment}) do
    %{data: render_one(customer_payment, CustomerPaymentView, "customer_payment.json")}
  end

  def render("customer_payment.json", %{customer_payment: customer_payment}) do
    %{
      id: customer_payment.id,
      order_id: customer_payment.order_id,
      iugu_invoice_id: customer_payment.iugu_invoice_id,
      installments: customer_payment.installments,
      total_amount: customer_payment.total_amount,
      discount: customer_payment.discount,
      state: customer_payment.state,
      card_brand: customer_payment.card_brand,
      card_last_digits: customer_payment.card_last_digits,
    }
  end
end
