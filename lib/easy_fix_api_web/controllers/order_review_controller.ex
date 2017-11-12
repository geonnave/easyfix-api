defmodule EasyFixApiWeb.OrderReviewController do
  use EasyFixApiWeb, :controller
  alias EasyFixApi.{Orders, CustomerOrders, Repo}
  alias EasyFixApi.Orders.{Quote, Matcher}

  @admin_key Application.get_env(:easy_fix_api, EasyFixApiWeb.Endpoint)[:secret_key_base]

  def index(conn, _params = %{"key" => @admin_key}) do
    orders = Orders.list_orders |> Enum.sort_by(fn order -> Timex.to_unix(order.inserted_at) end, &>=/2)
    render conn, "index.html", orders: orders
  end

  # TODO: refactor this ugly function...
  def show(conn, %{"id" => id, "key" => @admin_key}) do
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

    # accepted_quote = order.accepted_quote |> Orders.with_total_amount
    best_price_quote = order.best_price_quote |> Orders.with_total_amount
    %{total_amount: customer_best_price_total_amount} = case best_price_quote do
      nil -> %{total_amount: nil}
      best_price_quote -> CustomerOrders.add_customer_fee(best_price_quote)
    end

    render conn, "show.html",
      order: order,
      best_price_quote: best_price_quote,
      accepted_quote: best_price_quote,
      customer_best_price_total_amount: customer_best_price_total_amount,
      diag: diagnosis,
      customer: order.customer,
      garages_quotes: garages_quotes
  end
end
