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
      iugu_invoice_id: customer_payment.iugu_invoice_id,
      total_amount: customer_payment.total_amount,
      state: customer_payment.state
    }
  end
end
