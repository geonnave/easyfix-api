defmodule EasyFixApiWeb.CustomerQuoteView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.{CustomerQuoteView}
  alias EasyFixApi.{Orders}

  def render("index.json", %{customer_quotes: customer_quotes}) do
    %{data: render_many(customer_quotes, CustomerQuoteView, "customer_quote.json")}
  end

  def render("show.json", %{customer_quote: customer_quote}) do
    %{data: render_one(customer_quote, CustomerQuoteView, "customer_quote.json")}
  end

  def render("customer_quote.json", %{customer_quote: customer_quote}) do
    customer_quote
    |> Orders.with_total_amount
    |> Orders.add_customer_fee
    |> render_one(EasyFixApiWeb.QuoteView, "quote.json")
  end
end
