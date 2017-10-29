defmodule EasyFixApiWeb.CustomerOrderQuoteView do
  use EasyFixApiWeb, :view

  def render("show.json", %{customer_order_quotes: customer_order_quotes}) do
    %{data: render("customer_order_quotes.json", customer_order_quotes)}
  end

  def render("customer_order_quotes.json", customer_order_quotes) do
    %{
      best_price_quote: render_one(customer_order_quotes.best_price_quote, EasyFixApiWeb.QuoteView, "quote.json"),
      best_price_quote_issuer: render_one(customer_order_quotes.best_price_quote_issuer, EasyFixApiWeb.GarageView, "garage_contact.json"),
      best_price_quote_issuer_type: customer_order_quotes.best_price_quote_issuer_type,

      # FIXME: review this as soon as the frontend is refactored to allow proper number handling
      average_quote_price: __from_cents_to_reais_float(customer_order_quotes.average_quote_price),
      saving_from_worst_quote: __from_cents_to_reais_float(customer_order_quotes.saving_from_worst_quote),
      saving_from_average_quote: __from_cents_to_reais_float(customer_order_quotes.saving_from_average_quote),
    }
  end

  # FIXME: remove this as soon as the frontend is refactored to allow proper number handling
  def __from_cents_to_reais_float(amount) do
    Float.round(amount / 100, 2)
  end
end
