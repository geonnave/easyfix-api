defmodule EasyFixApiWeb.QuotePartView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.QuotePartView

  def render("index.json", %{quote_parts: quote_parts}) do
    %{data: render_many(quote_parts, QuotePartView, "quote_part.json")}
  end

  def render("show.json", %{quote_part: quote_part}) do
    %{data: render_one(quote_part, QuotePartView, "quote_part.json")}
  end

  def render("quote_part.json", %{quote_part: quote_part}) do
    %{id: quote_part.id,
      quantity: quote_part.quantity,
      price: quote_part.price.amount,
      part: render_one(quote_part.part, EasyFixApiWeb.PartView, "part.json"),
    }
  end
end
