defmodule EasyFixApi.GarageOrders do
  @moduledoc """
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.{Orders, Accounts, Repo}

  alias EasyFixApi.Orders.{Matcher, Quote}

  # must find intersection(garage_id_categories, diagnosis_categories)
  # TODO: write this using Ecto.Query
  def list_orders(garage_id) do
    garage = Accounts.get_garage!(garage_id)

    garage
    |> Matcher.list_orders_matching_garage
    |> Enum.map(fn order ->
      quote =
        garage.user.id
        |> Orders.get_quote_for_order_by_user(order.diagnosis.id)
        |> Orders.quote_with_best_price(order)
        |> Orders.with_total_amount

      order = Orders.order_maybe_with_customer(order, quote)

      best_price_quote =
        order.quotes
        |> Repo.preload(Quote.all_nested_assocs)
        |> Enum.map(&Orders.with_total_amount/1)
        |> Orders.sort_quotes_by_total_amount()
        |> List.first

      order = %{order | best_price_quote: best_price_quote}

      %{order: order, quote: quote}
    end)
    |> Enum.filter(fn %{order: order} -> order.diagnosis.diagnosis_parts != [] end)
  end

  # FIXME: make this function return nice error messages
  def get_order(garage_id, order_id) do
    garage = Accounts.get_garage!(garage_id)
    order = Orders.get_order!(order_id)

    quote =
      garage.user.id
      |> Orders.get_quote_for_order_by_user(order.diagnosis.id)
      |> Orders.quote_with_best_price(order)
      |> Orders.with_total_amount

    order = Orders.order_maybe_with_customer(order, quote)

    best_price_quote =
      order.quotes
      |> Repo.preload(Quote.all_nested_assocs)
      |> Enum.map(&Orders.with_total_amount/1)
      |> Orders.sort_quotes_by_total_amount()
      |> List.first

    order = %{order | best_price_quote: best_price_quote}

    %{order: order, quote: quote}
  end
end