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

  def delete_diagnosis(%Diagnosis{} = diagnosis) do
    Repo.delete(diagnosis)
  end

  alias EasyFixApi.Orders.Budget

  def list_budgets do
    Repo.all(Budget)
    |> Repo.preload(Budget.all_nested_assocs)
    |> Enum.map(&with_total_amount/1)
  end

  def list_budgets_by_order(order_id) do
    from(b in Budget,
      join: d in Diagnosis, on: d.id == b.diagnosis_id,
      join: o in Order, on: d.order_id == o.id,
      where: o.id == ^order_id,
      select: b,
      preload: ^Budget.all_nested_assocs)
    |> Repo.all
    |> Enum.map(&with_total_amount/1)
  end

  def get_budget!(id) do
    Repo.get!(Budget, id)
    |> Repo.preload(Budget.all_nested_assocs)
    |> with_total_amount()
  end

  def get_budget_for_order_by_user(user_id, diagnosis_id) do
    from(
      b in Budget,
      join: d in Diagnosis, on: b.diagnosis_id == d.id,
      preload: [budgets_parts: [part: ^Part.all_nested_assocs], issuer: [:garage]],
      where: b.issuer_id == ^user_id and d.id == ^diagnosis_id
    )
    |> Repo.one
    |> with_total_amount()
  end

  def get_budget_for_garage_order(garage_id, order_id) do
    case Accounts.get_user_by_type_id(:garage, garage_id) do
      nil ->
        {:error, "garage not found"}
      user ->
        from(b in Budget,
          join: d in Diagnosis, on: d.id == b.diagnosis_id,
          join: o in Order, on: d.order_id == o.id,
          where: o.id == ^order_id and b.issuer_id == ^user.id and b.issuer_type == "garage",
          select: b,
          preload: ^Budget.all_nested_assocs)
        |> Repo.one
        |> case do
          nil ->
            {:error, "budget not found"}
          budget ->
            {:ok, budget |> with_total_amount()}
        end
    end
  end

  def get_customer_best_budget(customer_id, order_id) do
    from(d in Diagnosis,
      join: o in Order, on: d.order_id == o.id,
      where: o.id == ^order_id and o.customer_id == ^customer_id,
      preload: [budgets: [budgets_parts: [part: ^EasyFixApi.Parts.Part.all_nested_assocs], issuer: [:garage]]])
    |> Repo.one
    |> case do
      nil ->
        {:error, "order not found for this customer"}
      diagnosis ->
        best_budget =
          diagnosis.budgets
          |> Enum.map(fn budget ->
            %{budget | total_amount: calculate_total_amount(budget)}
          end)
          |> Enum.sort(& &1.total_amount < &2.total_amount)
          |> List.first
          |> add_customer_fee()
        {:ok, best_budget}
    end
  end

  def with_total_amount(nil), do: nil
  def with_total_amount(budget) do
    %{budget | total_amount: calculate_total_amount(budget)}
  end

  def calculate_total_amount(budget) do
    calculate_total_amount(budget.budgets_parts, budget.service_cost)
  end
  def calculate_total_amount(budgets_parts, service_cost) do
    budgets_parts
    |> Enum.reduce(service_cost, fn budgets_parts, acc ->
      Money.add(acc, budgets_parts.price)
    end)
  end

  def add_customer_fee(budget) do
    whole_percent_fee = get_whole_percent_fee(budget)
    budgets_parts = Enum.map(budget.budgets_parts, fn budget_part ->
      %{budget_part | price: Money.multiply(budget_part.price, whole_percent_fee)}
    end)
    service_cost = Money.multiply(budget.service_cost, whole_percent_fee)
    total_amount = calculate_total_amount(budgets_parts, service_cost)

    %{budget | budgets_parts: budgets_parts, service_cost: service_cost, total_amount: total_amount}
  end

  def get_whole_percent_fee(budget) do
    customer_fee = Application.get_env(:easy_fix_api, :fees)[:customer_fee_on_budget_by_garage]

    budget.total_amount
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

  def create_budget(attrs \\ %{}) do
    with budget_changeset = %{valid?: true} <- Budget.create_changeset(attrs),
         %{diagnosis_id: diagnosis_id, issuer_type: issuer_type, issuer_id: issuer_id} = budget_changeset.changes,
         diagnosis when not is_nil(diagnosis) <- Repo.get(Diagnosis, diagnosis_id),
         issuer when not is_nil(issuer) <- Accounts.get_user_by_type_id(issuer_type, issuer_id) do

      Repo.transaction fn ->
        budget =
          budget_changeset
          |> delete_change(:issuer_id)
          |> put_assoc(:issuer, issuer)
          |> Repo.insert!()

        for part_attrs <- budget_changeset.changes[:parts] do
          case create_budget_part(part_attrs, budget.id) do
            {:error, budget_part_error_changeset} ->
              Repo.rollback(budget_part_error_changeset)
            _ ->
              nil
          end
        end

        budget
        |> Repo.preload(Budget.all_nested_assocs)
      end
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
      nil ->
        {:error, "budget or issuer does not exist"}
      error ->
        error
    end
  end

  def update_budget(%Budget{} = budget, attrs) do
    with budget_changeset = %{valid?: true} <- Budget.update_changeset(budget, attrs),
         parts_changes when not is_nil(parts_changes) <- budget_changeset.changes[:parts] do
      Repo.transaction fn ->
        for budget_part <- budget.budgets_parts do
          {:ok, _} = delete_budget_part(budget_part)
        end
        for part_attrs <- parts_changes do
          case create_budget_part(part_attrs, budget.id) do
            {:error, budget_part_error_changeset} ->
              Repo.rollback(budget_part_error_changeset)
            _ ->
              nil
          end
        end

        budget_changeset
        |> Repo.update!()

        get_budget!(budget.id)
      end
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
      nil ->
        {:error, "no parts to change"}
    end
  end

  def delete_budget(%Budget{} = budget) do
    Repo.delete(budget)
  end

  alias EasyFixApi.Orders.BudgetPart

  def create_budget_part(attrs \\ %{}, budget_id) do
    with budget_part_changeset = %{valid?: true} <- BudgetPart.create_changeset(attrs) do
        budget = get_budget!(budget_id)
        part = Parts.get_part!(budget_part_changeset.changes[:part_id])

        budget_part_changeset
        |> put_assoc(:part, part)
        |> put_assoc(:budget, budget)
        |> Repo.insert()
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  def update_budget_part(%BudgetPart{} = budget_part, attrs \\ %{}) do
    with budget_part_changeset = %{valid?: true} <- BudgetPart.update_changeset(budget_part, attrs) do
        budget_part_changeset
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

  def delete_budget_part(%BudgetPart{} = budget_part) do
    Repo.delete(budget_part)
  end

  alias EasyFixApi.Orders.Order

  def list_orders do
    Repo.all(Order)
    |> Repo.preload(Order.all_nested_assocs)
  end

  # must find intersection(garage_id_categories, diagnosis_categories)
  # TODO: write this using Ecto.Query
  def list_garage_order(garage_id) do
    garage = Accounts.get_garage!(garage_id)

    garage_categories_ids = 
      garage_id
      |> Accounts.get_garage_categories_ids!

    list_orders()
    |> Enum.filter(&order_matches_garage_categories?(&1, garage_categories_ids))
    |> Enum.map(fn order ->
      budget = get_budget_for_order_by_user(garage.user.id, order.diagnosis.id)
      %{order: order, budget: budget}
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

    _garage_categories_ids = 
      garage_id
      |> Accounts.get_garage_categories_ids!

    budget = get_budget_for_order_by_user(garage.user.id, order.diagnosis.id)
    %{order: order, budget: budget}
  end

  def order_matches_garage_categories?(_order = %{diagnosis: diagnosis}, garage_categories_ids) do
    diganostic_gc_ids = Enum.map(diagnosis.parts, & &1.garage_category_id)
    Enum.all?(garage_categories_ids, & Enum.member?(diganostic_gc_ids, &1))
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
        {:ok, diagnosis} = create_diagnosis(order_assoc_attrs[:diagnosis])
        state = :created_with_diagnosis

        order_changeset
        |> put_change(:state, state)
        |> put_change(:state_due_date, calculate_state_due_date(state))
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

  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end
end
