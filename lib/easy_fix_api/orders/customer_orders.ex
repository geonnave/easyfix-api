defmodule EasyFixApi.CustomerOrders do
  @moduledoc """
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.{Orders, Vouchers, Repo}

  alias EasyFixApi.Orders.{Order, Diagnosis, Quote}

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

  def get_order_quotes(customer_id, order_id) do
    from(d in Diagnosis,
      join: o in Order, on: d.order_id == o.id,
      where: o.id == ^order_id and o.customer_id == ^customer_id,
      preload: [quotes: [quotes_parts: [part: ^EasyFixApi.Parts.Part.all_nested_assocs],
                issuer: [:garage]], order: []])
    |> Repo.one
    |> case do
      nil ->
        {:error, "order not found for this customer"}
      %Diagnosis{order: %{state: order_state}} when order_state in [:not_quoted_by_garages] ->
        {:error, "this order was not quoted by any garage"}
      %Diagnosis{quotes: []} ->
        {:error, "there are no quotes for this order"}
      diagnosis ->
        {:ok, generate_customer_quotes_stats(diagnosis.quotes, customer_id)}
    end
  end

  def list_quotes do
    Orders.list_quotes
    |> Enum.map(&add_customer_fee/1)
  end

  def get_quote!(id) do
    Orders.get_quote!(id)
    |> add_customer_fee()
  end

  def generate_customer_quotes_stats([], _),  do: %{}
  def generate_customer_quotes_stats(quotes, customer_id) do
    sorted_quotes =
      quotes
      |> Repo.preload(Quote.all_nested_assocs)
      |> Enum.map(&Orders.with_total_amount/1)
      |> Enum.map(&add_customer_fee/1)
      |> Orders.sort_quotes_by_total_amount()

    best_price_quote =
      sorted_quotes
      |> List.first()
      |> maybe_add_voucher_discount(customer_id)

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

  def maybe_add_voucher_discount(quote, customer_id) do
    order = Repo.get(Order, quote.diagnosis.order_id) |> Repo.preload(payment: [:applied_voucher])
    case order.state do
      :quote_accepted_by_customer ->
        maybe_add_used_voucher(quote, order, customer_id)
      :created_with_diagnosis ->
        maybe_add_available_voucher(quote, customer_id)
      _ ->
        quote
    end
  end

  def maybe_add_used_voucher(quote, order = %{payment: payment}, customer_id) do
    case payment.applied_voucher do
      nil ->
        quote
      applied_voucher ->
        quote = add_voucher_extra_fee(quote)
        %{quote | voucher_discount: applied_voucher}
    end
  end

  def maybe_add_available_voucher(quote, customer_id) do
    customer_id
    |> Vouchers.list_available_indication_codes()
    |> case do
      [] ->
        quote
      [voucher_discount | _] ->
        quote = add_voucher_extra_fee(quote)
        %{quote | voucher_discount: voucher_discount}
    end
  end

  @doc """
  Add Voucher fee to compensate discount, when discount is greater than profit.

  If applicable, voucher_extra_fee = (discount - profit) / total_without_profit
  """
  def add_voucher_extra_fee(quote = %{service_cost: service_cost, total_amount: total_amount}) do
    discount = Money.new(Application.get_env(:easy_fix_api, :indication_coupons)[:discount])
    %{total_amount: total_amount_no_profit} = get_quote_without_customer_fee(quote.id)
    easyfix_profit = Money.subtract(total_amount, total_amount_no_profit)

    difference = Money.subtract(discount, easyfix_profit)
    if difference.amount > 0 do
      voucher_extra_fee = (difference.amount / total_amount_no_profit.amount)

      service_cost_with_voucher_fee = Money.add(service_cost, difference)
      total_amount_with_voucher_fee = Orders.calculate_total_amount(quote.quotes_parts, service_cost_with_voucher_fee)

      %{quote |
        service_cost: service_cost_with_voucher_fee,
        total_amount: total_amount_with_voucher_fee,
        voucher_extra_fee: voucher_extra_fee,
      }
    else
      quote
    end
  end

  def get_quote_without_customer_fee(quote_id) do
    Repo.get(Orders.Quote, quote_id)
    |> Repo.preload(:quotes_parts)
    |> Orders.with_total_amount
  end

  def add_customer_fee(quote = %{service_cost: service_cost, total_amount: total_amount}) do
    percent_fee = get_percent_fee(quote)

    easyfix_price = Money.multiply(total_amount, percent_fee)
    service_cost_for_customer = Money.add(service_cost, easyfix_price)
    total_amount_for_customer = Orders.calculate_total_amount(quote.quotes_parts, service_cost_for_customer)

    %{quote | service_cost: service_cost_for_customer, total_amount: total_amount_for_customer}
  end

  def get_percent_fee(%{easyfix_customer_fee: nil}) do
    Application.get_env(:easy_fix_api, :fees)[:customer_percent_fee_on_quote_by_garage]
  end
  def get_percent_fee(%{easyfix_customer_fee: easyfix_customer_fee}) do
    Decimal.to_float(easyfix_customer_fee)
  end
end
