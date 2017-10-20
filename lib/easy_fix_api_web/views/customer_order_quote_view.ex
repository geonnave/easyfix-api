defmodule EasyFixApiWeb.CustomerOrderQuoteView do
  use EasyFixApiWeb, :view

  def render("best_quote.json", %{customer_best_quote: customer_best_quote}) do
    %{data: render_one(customer_best_quote, EasyFixApiWeb.QuoteView, "quote.json")}
  end
end
