defmodule EasyFixApi.Orders do
  @moduledoc """
  The boundary for the Orders system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.{Parts, Accounts, Repo, Helpers}

  alias EasyFixApi.Parts.Part
  alias EasyFixApi.Cars.Vehicle
  alias EasyFixApi.Orders.{DiagnosisPart, Order, Diagnosis}

  def create_diagnosis_part(attrs \\ %{}, diagnosis_id) do
    with diagnosis_part_changeset = %{valid?: true} <- DiagnosisPart.create_changeset(attrs) do
      diagnosis = get_diagnosis!(diagnosis_id)
      part = Parts.get_part!(diagnosis_part_changeset.changes[:part_id])

      diagnosis_part_changeset
      |> put_assoc(:part, part)
      |> put_assoc(:diagnosis, diagnosis)
      |> Repo.insert()
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  def update_diagnosis_part(%DiagnosisPart{} = diagnosis_part, attrs \\ %{}) do
    with diagnosis_part_changeset = %{valid?: true} <- DiagnosisPart.update_changeset(diagnosis_part, attrs) do
        diagnosis_part_changeset
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

  def delete_diagnosis_part(%DiagnosisPart{} = diagnosis_part) do
    Repo.delete(diagnosis_part)
  end

  def all_repair_by_fixer?(diagnosis_parts) do
    diagnosis_parts
    |> Enum.all?(fn %{part: part} -> part.repair_by_fixer end)
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
         %{vehicle_id: vehicle_id} = diagnosis_changeset.changes,
         vehicle when not is_nil(vehicle) <- Repo.get(Vehicle, vehicle_id) do

      Repo.transaction fn ->
        diagnosis =
          diagnosis_changeset
          |> delete_change(:vehicle_id)
          |> put_assoc(:vehicle, vehicle)
          |> Repo.insert!()

        for part_attrs <- diagnosis_changeset.changes[:parts] do
          case create_diagnosis_part(part_attrs, diagnosis.id) do
            {:error, diagnosis_part_error_changeset} ->
              Repo.rollback(diagnosis_part_error_changeset)
            _ ->
              nil
          end
        end

        diagnosis
        |> Repo.preload(Diagnosis.all_nested_assocs)
      end
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
      nil ->
        {:error, "vehicle does not exist"}
      error ->
        error
    end
  end

  def update_diagnosis(%Diagnosis{} = diagnosis, attrs) do
    with diagnosis_changeset = %{valid?: true} <- Diagnosis.update_changeset(diagnosis, attrs) do
      Repo.transaction fn ->
        if diagnosis_changeset.changes[:parts] do
          for diagnosis_part <- diagnosis.diagnosis_parts do
            {:ok, _} = delete_diagnosis_part(diagnosis_part)
          end
          for part_attrs <- diagnosis_changeset.changes[:parts] do
            case create_diagnosis_part(part_attrs, diagnosis.id) do
              {:error, diagnosis_part_error_changeset} ->
                Repo.rollback(diagnosis_part_error_changeset)
              _ ->
                nil
            end
          end
        end

        diagnosis_changeset
        |> Repo.update!()

        get_diagnosis!(diagnosis.id)
      end
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  def update_diagnosis_expiration(%Diagnosis{} = diagnosis, attrs) do
    diagnosis
    |> Diagnosis.update_expiration_changeset(attrs)
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

  # TODO: rename `user` to `issuer` in this function
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

  def garage_or_fixer?(issuer) do
    issuer.garage_categories
    |> Enum.any?(& &1.name == "Autônomo")
    |> case do
      true ->
        :fixer
      false ->
        :garage
    end
  end

  def quote_issuer(%{issuer_type: :garage, issuer: issuer}) do
    issuer.garage
    |> Repo.preload([:address, :user, :garage_categories])
  end

  def average_quote_price(quotes) do
    quotes
    |> Enum.reduce(0, fn a_quote, acc -> acc + a_quote.total_amount.amount end)
    |> Kernel./(length(quotes))
    |> Kernel.round
  end

  def sort_quotes_by_total_amount(quotes) do
    Enum.sort(quotes, &(&1.total_amount < &2.total_amount))
  end

  def is_best_price_quote(order, quote_id) do
    list_quotes_by_order(order.id)
    |> sort_quotes_by_total_amount()
    |> List.first()
    |> case do
      nil ->
        false
      best_price_quote ->
        best_price_quote.id == quote_id
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
    |> Enum.reduce(service_cost, fn quote_part, acc ->
      quote_part.price
      |> Money.multiply(quote_part.quantity)
      |> Money.add(acc)
    end)
  end

  def create_quote(attrs \\ %{}) do
    with quote_changeset = %{valid?: true} <- Quote.create_changeset(attrs),
         %{diagnosis_id: diagnosis_id, issuer_type: issuer_type, issuer_id: issuer_id} = quote_changeset.changes,
         diagnosis when not is_nil(diagnosis) <- Repo.get(Diagnosis, diagnosis_id),
         issuer when not is_nil(issuer) <- Accounts.get_user_by_type_id(issuer_type, issuer_id) do

      Repo.transaction fn ->
        easyfix_customer_fee = Application.get_env(:easy_fix_api, :fees)[:customer_percent_fee_on_quote_by_garage]

        quote =
          quote_changeset
          |> delete_change(:issuer_id)
          |> put_assoc(:issuer, issuer)
          |> put_change(:easyfix_customer_fee, easyfix_customer_fee)
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
        |> with_total_amount()
        |> case do
          %{total_amount: %Money{amount: 0}} ->
            Repo.rollback("Quote total amount cannot be 0")
          quote ->
            quote
        end
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

  alias EasyFixApi.Orders.{Order, OrderStateMachine}

  def list_orders do
    Repo.all(Order)
    |> Repo.preload(Order.all_nested_assocs)
  end

  def quote_with_best_price(nil, _order), do: nil
  def quote_with_best_price(quote, order) do
    %{quote | is_best_price: order.best_price_quote_id == quote.id}
  end

  def order_maybe_with_customer(order, nil), do: %{order | customer: nil}
  def order_maybe_with_customer(order, quote) do
    if order.state in [:quote_accepted_by_customer] and quote.is_best_price do
      order
    else
      %{order | customer: nil}
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

  def get_order_for_quote(quote_id) do
    from(o in Order,
      join: d in Diagnosis, on: d.order_id == o.id,
      join: q in Quote, on: q.diagnosis_id == d.id,
      where: q.id == ^quote_id,
      preload: ^Order.all_nested_assocs)
    |> Repo.one
  end

  def create_order_with_diagnosis(attrs \\ %{}) do
    with order_changeset = %{valid?: true} <- Order.create_changeset(attrs),
         order_assoc_changeset = %{valid?: true} <- Order.assoc_changeset(attrs),
         order_assoc_attrs <- Helpers.apply_changes_ensure_atom_keys(order_assoc_changeset) do

      customer = Accounts.get_customer!(order_assoc_attrs[:customer_id])
      Repo.transaction fn ->
        {:ok, diagnosis} = create_diagnosis(order_assoc_attrs[:diagnosis])

        state = :created_with_diagnosis

        state_due_date =
          diagnosis.diagnosis_parts
          |> all_repair_by_fixer?()
          |> case do
            true ->
              EasyFixApi.Orders.StateTimeouts.get()[state][:fixer_timeout][:value]
            false ->
              EasyFixApi.Orders.StateTimeouts.get()[state][:timeout][:value]
          end
          |> OrderStateMachine.calculate_due_date_from_now()

        {:ok, diagnosis} = update_diagnosis_expiration(diagnosis, %{expiration_date: state_due_date})

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

  def set_order_best_price_quote(%Order{} = order, attrs) do
    order
    |> Order.set_best_price_quote_changeset(attrs)
    |> Repo.update()
  end

  def set_order_rating(%Order{} = order, attrs) do
    order
    |> Order.set_rating_changeset(attrs)
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
