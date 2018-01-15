defmodule EasyFixApiWeb.GarageOrderView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.{GarageOrderView, DateView}

  def render("index.json", %{garage_orders: garage_orders}) do
    %{data: render_many(garage_orders, GarageOrderView, "garage_order.json")}
  end

  def render("show.json", %{garage_order: garage_order}) do
    %{data: render_one(garage_order, GarageOrderView, "garage_order.json")}
  end

  def render("garage_order.json", %{garage_order: garage_order}) do
    order = garage_order.order
    quote = garage_order.quote
    %{id: order.id,
      state: order.state,
      state_due_date: DateView.render("iso_at_sao_paulo_tz", order.state_due_date),
      opening_date: DateView.render("iso_at_sao_paulo_tz", order.inserted_at),
      conclusion_date: DateView.render("iso_at_sao_paulo_tz", order.conclusion_date),
      customer: render_one(order.customer, EasyFixApiWeb.CustomerView, "customer_contact.json"),
      diagnosis: render_one(order.diagnosis, EasyFixApiWeb.DiagnosisView, "diagnosis.json"),
      quote: render_one(quote, EasyFixApiWeb.QuoteView, "quote.json"),
      best_quote: (if order.best_price_quote, do: __from_cents_to_reais_float(order.best_price_quote.total_amount.amount), else: nil),
      accepted_quote_id: order.accepted_quote_id,
      rating: order.rating,
      rating_comment: order.rating_comment,
    }
  end

  # FIXME: remove this as soon as the frontend is refactored to allow proper number handling
  def __from_cents_to_reais_float(amount) do
    Float.round(amount / 100, 2)
  end
end
