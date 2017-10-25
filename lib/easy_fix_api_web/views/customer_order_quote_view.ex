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
      average_quote_price: customer_order_quotes.average_quote_price,
      saving_from_worst_quote: customer_order_quotes.saving_from_worst_quote,
      saving_from_average_quote: customer_order_quotes.saving_from_average_quote,
    }
  end
end
