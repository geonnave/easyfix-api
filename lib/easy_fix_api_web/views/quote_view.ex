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
      state: quote.state,
      opening_date: DateView.render("iso_at_sao_paulo_tz", quote.inserted_at),
      due_date: DateView.render("iso_at_sao_paulo_tz", quote.due_date),
      conclusion_date: DateView.render("iso_at_sao_paulo_tz", quote.conclusion_date),
      comment: quote.comment,

      parts: render_many(quote.quotes_parts, EasyFixApiWeb.QuotePartView, "quote_part.json"),

      # FIXME: review this as soon as the frontend is refactored to allow proper number handling
      service_cost: __from_cents_to_reais_float(quote.service_cost.amount),
      total_amount: (if quote.total_amount, do: __from_cents_to_reais_float(quote.total_amount.amount), else: nil),

      is_best_price: quote.is_best_price,
      diagnosis_id: quote.diagnosis_id,
      issuer_type: quote.issuer_type,
      issuer_id: Map.get(quote.issuer, quote.issuer_type).id,
    }
  end

  # FIXME: remove this as soon as the frontend is refactored to allow proper number handling
  def __from_cents_to_reais_float(amount) do
    Float.round(amount / 100, 2)
  end
end
