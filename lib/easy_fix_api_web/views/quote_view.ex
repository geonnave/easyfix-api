defmodule EasyFixApiWeb.QuoteView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.{QuoteView, DateView}

  def render("index.json", %{quotes: quotes}) do
    %{data: render_many(quotes, QuoteView, "quote.json")}
  end

  def render("show.json", %{quote: quote}) do
    %{data: render_one(quote, QuoteView, "quote.json")}
  end

  def render("quote.json", %{quote: quote}) do
    %{id: quote.id,
      service_cost: quote.service_cost.amount,
      state: quote.state,
      opening_date: DateView.render("iso_at_sao_paulo_tz", quote.inserted_at),
      due_date: DateView.render("iso_at_sao_paulo_tz", quote.due_date),
      conclusion_date: DateView.render("iso_at_sao_paulo_tz", quote.conclusion_date),
      parts: render_many(quote.quotes_parts, EasyFixApiWeb.QuotePartView, "quote_part.json"),
      total_amount: (if quote.total_amount, do: quote.total_amount.amount, else: nil),
      diagnosis_id: quote.diagnosis_id,
      issuer_type: quote.issuer_type,
      issuer_id: Map.get(quote.issuer, quote.issuer_type).id,
    }
  end
end
