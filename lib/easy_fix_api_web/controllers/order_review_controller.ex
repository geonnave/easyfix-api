defmodule EasyFixApiWeb.OrderReviewController do
  use EasyFixApiWeb, :controller
  alias EasyFixApi.{Orders, Parts, Repo}
  alias EasyFixApi.Orders.{Order, Quote, Matcher}

  def index(conn, _params) do
    orders = Orders.list_orders |> Enum.sort_by(fn order -> Timex.to_unix(order.inserted_at) end, &>=/2)
    render conn, "index.html", orders: orders
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order!(id)
    diagnosis = order.diagnosis
    %{quotes: quotes} = order.diagnosis |> Repo.preload(quotes: [Quote.all_nested_assocs])

    garages_quotes =
      order
      |> Matcher.list_garages_matching_order
      |> Enum.map(fn garage ->
        quotes
        |> Enum.find(& &1.issuer_id == garage.user_id)
        |> case do
          nil ->
            {garage, nil}
          quote ->
            {garage, Orders.with_total_amount(quote)}
        end
      end)
      |> Enum.sort(fn
        {_, nil}, {_, nil} -> true
        {_, nil}, {_, _q2} -> false
        {_, _q1}, {_, nil} -> true
        {_, q1}, {_, q2} -> q1.total_amount >= q2.total_amount
      end)

    render conn, "show.html",
      order: order,
      best_price_quote: order.best_price_quote |> Orders.with_total_amount,
      accepted_quote: order.accepted_quote |> Orders.with_total_amount,
      diag: diagnosis,
      customer: order.customer,
      garages_quotes: garages_quotes
  end
end
