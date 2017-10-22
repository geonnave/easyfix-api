defmodule EasyFixApiWeb.OrderView do
  use EasyFixApiWeb, :view
  alias EasyFixApiWeb.{OrderView, DateView}

  def render("index.json", %{orders: orders}) do
    %{data: render_many(orders, OrderView, "order.json")}
  end

  def render("show.json", %{order: order}) do
    %{data: render_one(order, OrderView, "order.json")}
  end

  def render("order.json", %{order: order}) do
    %{id: order.id,
      state: order.state,
      state_due_date: DateView.render("iso_at_sao_paulo_tz", order.state_due_date),
      opening_date: DateView.render("iso_at_sao_paulo_tz", order.inserted_at),
      conclusion_date: DateView.render("iso_at_sao_paulo_tz", order.conclusion_date),
      diagnosis: render_one(order.diagnosis, EasyFixApiWeb.DiagnosisView, "diagnosis.json"),
      customer_id: order.customer_id,
      accepted_quote_id: order.accepted_quote_id,
      rating: order.rating,
      rating_comment: order.rating_comment,
    }
  end
end
