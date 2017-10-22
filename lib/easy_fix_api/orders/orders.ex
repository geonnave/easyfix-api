defmodule EasyFixApi.Orders do
  @moduledoc """
  The boundary for the Orders system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.{Parts, Accounts, Repo, Helpers}

  alias EasyFixApi.Parts.Part
  alias EasyFixApi.Orders.{DiagnosisPart, Order, Diagnosis}

  def create_diagnosis_part(attrs \\ %{}, diagnosis_id) do
    with diagnosis_part_changeset = %{valid?: true} <- DiagnosisPart.create_changeset(attrs),
         diagnosis_part_assoc_changeset = %{valid?: true} <- DiagnosisPart.assoc_changeset(attrs),
         diagnosis_part_assoc_attrs <- Helpers.apply_changes_ensure_atom_keys(diagnosis_part_assoc_changeset) do

        part = Parts.get_part!(diagnosis_part_assoc_attrs[:part_id])
        diagnosis = get_diagnosis!(diagnosis_id)

        diagnosis_part_changeset
        |> put_assoc(:part, part)
        |> put_assoc(:diagnosis, diagnosis)
        |> Repo.insert()
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  # Diagnosis

  def list_diagnosis do
    Repo.all(Diagnosis)
    |> Repo.preload(Diagnosis.all_nested_assocs)
  end

  def get_diagnosis!(id) do
    Repo.get!(Diagnosis, id)
    |> Repo.preload(Diagnosis.all_nested_assocs)
  end

  def create_diagnosis(attrs \\ %{}) do
    with diagnosis_changeset = %{valid?: true} <- Diagnosis.create_changeset(attrs),
         diagnosis_assoc_changeset = %{valid?: true} <- Diagnosis.assoc_changeset(attrs),
         diagnosis_assoc_attrs <- Helpers.apply_changes_ensure_atom_keys(diagnosis_assoc_changeset) do

      vehicle = EasyFixApi.Cars.get_vehicle!(diagnosis_assoc_attrs[:vehicle_id])
      Repo.transaction fn ->
        diagnosis_changeset
        |> put_assoc(:vehicle, vehicle)
        |> Repo.insert()
        |> case do
          {:ok, diagnosis} ->
            for part_attrs <- diagnosis_assoc_attrs[:parts] do
              case create_diagnosis_part(part_attrs, diagnosis.id) do
                {:error, diagnosis_part_error_changeset} ->
                  Repo.rollback(diagnosis_part_error_changeset)
                _ ->
                  nil
              end
            end
            Repo.preload(diagnosis, Diagnosis.all_nested_assocs)
          error ->
            error
        end
      end
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  def update_diagnosis(%Diagnosis{} = diagnosis, attrs) do
    diagnosis
    |> Diagnosis.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_diagnosis(%Diagnosis{} = diagnosis) do
    Repo.delete(diagnosis)
  end

  alias EasyFixApi.Orders.Quote

  def list_quotes do
    Repo.all(Quote)
    |> Repo.preload(Quote.all_nested_assocs)
    |> Enum.map(&with_total_amount/1)
  end

  def list_quotes_by_order(order_id) do
    from(b in Quote,
      join: d in Diagnosis, on: d.id == b.diagnosis_id,
      join: o in Order, on: d.order_id == o.id,
      where: o.id == ^order_id,
      select: b,
      preload: ^Quote.all_nested_assocs)
    |> Repo.all
    |> Enum.map(&with_total_amount/1)
  end

  def get_quote!(id) do
    Repo.get!(Quote, id)
    |> Repo.preload(Quote.all_nested_assocs)
    |> with_total_amount()
  end

  def get_quote_for_order_by_user(user_id, diagnosis_id) do
    from(
      b in Quote,
      join: d in Diagnosis, on: b.diagnosis_id == d.id,
      preload: [quotes_parts: [part: ^Part.all_nested_assocs], issuer: [:garage]],
      where: b.issuer_id == ^user_id and d.id == ^diagnosis_id
    )
    |> Repo.one
    |> with_total_amount()
  end

  def get_quote_for_garage_order(garage_id, order_id) do
    case Accounts.get_user_by_type_id(:garage, garage_id) do
      nil ->
        {:error, "garage not found"}
      user ->
        from(b in Quote,
          join: d in Diagnosis, on: d.id == b.diagnosis_id,
          join: o in Order, on: d.order_id == o.id,
          where: o.id == ^order_id and b.issuer_id == ^user.id and b.issuer_type == "garage",
          select: b,
          preload: ^Quote.all_nested_assocs)
        |> Repo.one
        |> case do
          nil ->
            {:error, "quote not found"}
          quote ->
            {:ok, quote |> with_total_amount()}
        end
    end
  end

  def get_customer_best_quote(customer_id, order_id) do
    from(d in Diagnosis,
      join: o in Order, on: d.order_id == o.id,
      where: o.id == ^order_id and o.customer_id == ^customer_id,
      preload: [quotes: [quotes_parts: [part: ^EasyFixApi.Parts.Part.all_nested_assocs], issuer: [:garage]]])
    |> Repo.one
    |> case do
      nil ->
        {:error, "order not found for this customer"}
      diagnosis ->
        best_quote =
          diagnosis.quotes
          |> Enum.map(fn quote ->
            %{quote | total_amount: calculate_total_amount(quote)}
          end)
          |> Enum.sort(& &1.total_amount < &2.total_amount)
          |> List.first
          |> add_customer_fee()
        {:ok, best_quote}
    end
  end

  def with_total_amount(nil), do: nil
  def with_total_amount(quote) do
    %{quote | total_amount: calculate_total_amount(quote)}
  end

  def calculate_total_amount(quote) do
    calculate_total_amount(quote.quotes_parts, quote.service_cost)
  end
  def calculate_total_amount(quotes_parts, service_cost) do
    quotes_parts
    |> Enum.reduce(service_cost, fn quotes_parts, acc ->
      Money.add(acc, quotes_parts.price)
    end)
  end

  def add_customer_fee(quote) do
    whole_percent_fee = get_whole_percent_fee(quote)
    quotes_parts = Enum.map(quote.quotes_parts, fn quote_part ->
      %{quote_part | price: Money.multiply(quote_part.price, whole_percent_fee)}
    end)
    service_cost = Money.multiply(quote.service_cost, whole_percent_fee)
    total_amount = calculate_total_amount(quotes_parts, service_cost)

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

  def create_quote(attrs \\ %{}) do
    with quote_changeset = %{valid?: true} <- Quote.create_changeset(attrs),
         %{diagnosis_id: diagnosis_id, issuer_type: issuer_type, issuer_id: issuer_id} = quote_changeset.changes,
         diagnosis when not is_nil(diagnosis) <- Repo.get(Diagnosis, diagnosis_id),
         issuer when not is_nil(issuer) <- Accounts.get_user_by_type_id(issuer_type, issuer_id) do

      Repo.transaction fn ->
        quote =
          quote_changeset
          |> delete_change(:issuer_id)
          |> put_assoc(:issuer, issuer)
          |> Repo.insert!()

        for part_attrs <- quote_changeset.changes[:parts] do
          case create_quote_part(part_attrs, quote.id) do
            {:error, quote_part_error_changeset} ->
              Repo.rollback(quote_part_error_changeset)
            _ ->
              nil
          end
        end

        quote
        |> Repo.preload(Quote.all_nested_assocs)
      end
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
      nil ->
        {:error, "quote or issuer does not exist"}
      error ->
        error
    end
  end

  def update_quote(%Quote{} = quote, attrs) do
    with quote_changeset = %{valid?: true} <- Quote.update_changeset(quote, attrs),
         parts_changes when not is_nil(parts_changes) <- quote_changeset.changes[:parts] do
      Repo.transaction fn ->
        for quote_part <- quote.quotes_parts do
          {:ok, _} = delete_quote_part(quote_part)
        end
        for part_attrs <- parts_changes do
          case create_quote_part(part_attrs, quote.id) do
            {:error, quote_part_error_changeset} ->
              Repo.rollback(quote_part_error_changeset)
            _ ->
              nil
          end
        end

        quote_changeset
        |> Repo.update!()

        get_quote!(quote.id)
      end
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
      nil ->
        {:error, "no parts to change"}
    end
  end

  def delete_quote(%Quote{} = quote) do
    Repo.delete(quote)
  end

  alias EasyFixApi.Orders.QuotePart

  def create_quote_part(attrs \\ %{}, quote_id) do
    with quote_part_changeset = %{valid?: true} <- QuotePart.create_changeset(attrs) do
        quote = get_quote!(quote_id)
        part = Parts.get_part!(quote_part_changeset.changes[:part_id])

        quote_part_changeset
        |> put_assoc(:part, part)
        |> put_assoc(:quote, quote)
        |> Repo.insert()
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  def update_quote_part(%QuotePart{} = quote_part, attrs \\ %{}) do
    with quote_part_changeset = %{valid?: true} <- QuotePart.update_changeset(quote_part, attrs) do
        quote_part_changeset
        |> case do
          changeset = %{changes: %{part_id: part_id}} ->
            part = Parts.get_part!(part_id)
            put_assoc(changeset, :part, part)
          changeset ->
            changeset
        end
        |> Repo.update()
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  def delete_quote_part(%QuotePart{} = quote_part) do
    Repo.delete(quote_part)
  end

  alias EasyFixApi.Orders.{Order, Matcher}

  def list_orders do
    Repo.all(Order)
    |> Repo.preload(Order.all_nested_assocs)
  end

  # must find intersection(garage_id_categories, diagnosis_categories)
  # TODO: write this using Ecto.Query
  def list_garage_orders(garage_id) do
    garage = Accounts.get_garage!(garage_id)

    garage
    |> Matcher.list_orders_matching_garage
    |> Enum.map(fn order ->
      quote = get_quote_for_order_by_user(garage.user.id, order.diagnosis.id)
      %{order: order, quote: quote}
    end)
  end

  def list_customer_orders(customer_id) do
    from(o in Order,
      where: o.customer_id == ^customer_id,
      preload: ^Order.all_nested_assocs)
    |> Repo.all
  end

  # FIXME: make this function return nice error messages
  def get_garage_order(garage_id, order_id) do
    garage = Accounts.get_garage!(garage_id)
    order = get_order!(order_id)

    quote = get_quote_for_order_by_user(garage.user.id, order.diagnosis.id)
    %{order: order, quote: quote}
  end

  def get_customer_order(customer_id, order_id) do
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

  def get_order!(id) do
    Repo.get!(Order, id)
    |> Repo.preload(Order.all_nested_assocs)
  end
  def get_order(id) do
    case Repo.get(Order, id) do
      nil ->
        {:error, "Order not found"}
      order ->
        {:ok, Repo.preload(order, Order.all_nested_assocs)}
    end
  end

  def calculate_state_due_date(state) do
    case Application.get_env(:easy_fix_api, :order_states)[state][:timeout] do
      nil ->
        nil
      timeout_data ->
        Timex.now |> Timex.shift(timeout_data[:value])
    end
  end

  def create_order_with_diagnosis(attrs \\ %{}) do
    with order_changeset = %{valid?: true} <- Order.create_changeset(attrs),
         order_assoc_changeset = %{valid?: true} <- Order.assoc_changeset(attrs),
         order_assoc_attrs <- Helpers.apply_changes_ensure_atom_keys(order_assoc_changeset) do

      customer = Accounts.get_customer!(order_assoc_attrs[:customer_id])
      Repo.transaction fn ->
        state = :created_with_diagnosis
        state_due_date = calculate_state_due_date(state)

        {:ok, diagnosis} = create_diagnosis(order_assoc_attrs[:diagnosis])
        {:ok, diagnosis} = update_diagnosis(diagnosis, %{expiration_date: state_due_date})

        order_changeset
        |> put_change(:state, state)
        |> put_change(:state_due_date, state_due_date)
        |> put_assoc(:diagnosis, diagnosis)
        |> put_assoc(:customer, customer)
        |> Repo.insert()
        |> case do
          {:ok, order} ->
            Repo.preload(order, Order.all_nested_assocs)
          error ->
            error
        end
      end
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  def update_order_state(%Order{} = order, attrs) do
    order
    |> Order.update_state_changeset(attrs)
    |> Repo.update()
  end

  def set_order_accepted_quote(%Order{} = order, attrs) do
    order
    |> Order.set_accepted_quote_changeset(attrs)
    |> Repo.update()
  end

  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end
end
