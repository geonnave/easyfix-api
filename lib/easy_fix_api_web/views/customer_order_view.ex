defmodule EasyFixApiWeb.CustomerOrderView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.{CustomerOrderView, DateView}

  def render("index.json", %{customer_orders: customer_orders}) do
    %{data: render_many(customer_orders, CustomerOrderView, "customer_order.json")}
  end

  def render("show.json", %{customer_order: customer_order}) do
    %{data: render_one(customer_order, CustomerOrderView, "customer_order.json")}
  end

  def render("customer_order.json", %{customer_order: customer_order}) do
    %{id: customer_order.id,
      state: customer_order.state,
      state_due_date: DateView.render("iso_at_sao_paulo_tz", customer_order.state_due_date),
      opening_date: DateView.render("iso_at_sao_paulo_tz", customer_order.inserted_at),
      conclusion_date: DateView.render("iso_at_sao_paulo_tz", customer_order.conclusion_date),
      diagnosis: render_one(customer_order.diagnosis, EasyFixApiWeb.DiagnosisView, "diagnosis.json"),
      customer_id: customer_order.customer_id,
      best_price_quote_id: customer_order.best_price_quote_id,
      accepted_quote: render_one(customer_order.accepted_quote, EasyFixApiWeb.CustomerQuoteView, "customer_quote.json"),
      rating: customer_order.rating,
      rating_comment: customer_order.rating_comment,
      payment: render_one(customer_order.payment, EasyFixApiWeb.CustomerPaymentView, "customer_payment.json"),
    }
  end
end
