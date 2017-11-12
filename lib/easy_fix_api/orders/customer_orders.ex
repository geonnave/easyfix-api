defmodule EasyFixApi.CustomerOrders do
  @moduledoc """
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.{Orders, Parts, Accounts, Repo, Helpers}

  alias EasyFixApi.Parts.Part
  alias EasyFixApi.Cars.Vehicle
  alias EasyFixApi.Orders.{DiagnosisPart, Order, Diagnosis, Quote}

  def list_orders(customer_id) do
    from(o in Order,
      where: o.customer_id == ^customer_id,
      preload: ^Order.all_nested_assocs)
    |> Repo.all
  end

  def get_order(customer_id, order_id) do
    from(o in Order,
      where: o.customer_id == ^customer_id and o.id == ^order_id,
      preload: ^Order.all_nested_assocs)
    |> Repo.one
    |> case do
      nil ->
        {:error, "order #{order_id} not found for customer #{customer_id}"}
      order ->
        {:ok, order}
    end
  end

  def get_customer_order_quotes(customer_id, order_id) do
    from(d in Diagnosis,
      join: o in Order, on: d.order_id == o.id,
      where: o.id == ^order_id and o.customer_id == ^customer_id,
      preload: [quotes: [quotes_parts: [part: ^EasyFixApi.Parts.Part.all_nested_assocs],
                issuer: [:garage]], order: []])
    |> Repo.one
    |> case do
      nil ->
        {:error, "order not found for this customer"}
      %Diagnosis{order: %{state: order_state}} when order_state in [:created_with_diagnosis] ->
        {:error, "garages are still quoting this order"}
      %Diagnosis{order: %{state: order_state}} when order_state in [:not_quoted_by_garages] ->
        {:error, "this order was not quoted by any garage"}
      %Diagnosis{quotes: []} ->
        {:error, "there are no quotes for this order"}
      diagnosis ->
        {:ok, generate_customer_quotes_stats(diagnosis.quotes)}
    end
  end

  def generate_customer_quotes_stats([]),  do: %{}
  def generate_customer_quotes_stats(quotes) do
    sorted_quotes =
      quotes
      |> Repo.preload(Quote.all_nested_assocs)
      |> Enum.map(&Orders.with_total_amount/1)
      |> Enum.map(&add_customer_fee/1)
      |> Orders.sort_quotes_by_total_amount()

    best_price_quote = List.first(sorted_quotes)
    best_price_quote_issuer = Orders.quote_issuer(best_price_quote)
    worst_price_quote = List.last(sorted_quotes)
    average_quote_price = Orders.average_quote_price(sorted_quotes)

    %{
      best_price_quote: best_price_quote,
      best_price_quote_issuer: best_price_quote_issuer,
      best_price_quote_issuer_type: Orders.garage_or_fixer?(best_price_quote_issuer),
      average_quote_price: average_quote_price,
      worst_quote_price: worst_price_quote.total_amount.amount,
      saving_from_worst_quote: worst_price_quote.total_amount.amount - best_price_quote.total_amount.amount,
      saving_from_average_quote: average_quote_price - best_price_quote.total_amount.amount,
    }
  end

  def add_customer_fee(quote) do
    whole_percent_fee = get_whole_percent_fee(quote)
    quotes_parts = Enum.map(quote.quotes_parts, fn quote_part ->
      %{quote_part | price: Money.multiply(quote_part.price, whole_percent_fee)}
    end)
    service_cost = Money.multiply(quote.service_cost, whole_percent_fee)
    total_amount = Orders.calculate_total_amount(quotes_parts, service_cost)

    %{quote | quotes_parts: quotes_parts, service_cost: service_cost, total_amount: total_amount}
  end

  def get_whole_percent_fee(quote) do
    customer_fee = Application.get_env(:easy_fix_api, :fees)[:customer_fee_on_quote_by_garage]

    quote.total_amount
    |> calculate_customer_percent_fee(Money.new(customer_fee[:max_amount]), customer_fee[:percent_fee])
    |> Kernel.+(1)
  end

  def calculate_customer_percent_fee(total_amount, max_amount, percent_fee) do
    if Money.multiply(total_amount, percent_fee) > max_amount do
      (max_amount.amount / total_amount.amount) |> Float.round(4)
    else
      percent_fee
    end
  end
end