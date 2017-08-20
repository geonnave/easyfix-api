defmodule EasyFixApi.Orders do
  @moduledoc """
  The boundary for the Orders system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.{Parts, Accounts, Repo, Helpers}

  alias EasyFixApi.Orders.DiagnosticPart

  def create_diagnostic_part(attrs \\ %{}, diagnostic_id) do
    with diagnostic_part_changeset = %{valid?: true} <- DiagnosticPart.create_changeset(attrs),
         diagnostic_part_assoc_changeset = %{valid?: true} <- DiagnosticPart.assoc_changeset(attrs),
         diagnostic_part_assoc_attrs <- Helpers.apply_changes_ensure_atom_keys(diagnostic_part_assoc_changeset) do

        part = Parts.get_part!(diagnostic_part_assoc_attrs[:part_id])
        diagnostic = get_diagnostic!(diagnostic_id)

        diagnostic_part_changeset
        |> put_assoc(:part, part)
        |> put_assoc(:diagnostic, diagnostic)
        |> Repo.insert()
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  alias EasyFixApi.Orders.Diagnostic

  def list_diagnostics do
    Repo.all(Diagnostic)
    |> Repo.preload(Diagnostic.all_nested_assocs)
  end

  def get_diagnostic!(id) do
    Repo.get!(Diagnostic, id)
    |> Repo.preload(Diagnostic.all_nested_assocs)
  end

  def create_diagnostic(attrs \\ %{}) do
    with diagnostic_changeset = %{valid?: true} <- Diagnostic.create_changeset(attrs),
         diagnostic_assoc_changeset = %{valid?: true} <- Diagnostic.assoc_changeset(attrs),
         diagnostic_assoc_attrs <- Helpers.apply_changes_ensure_atom_keys(diagnostic_assoc_changeset) do

      vehicle = EasyFixApi.Cars.get_vehicle!(diagnostic_assoc_attrs[:vehicle_id])
      Repo.transaction fn ->
        diagnostic_changeset
        |> put_assoc(:vehicle, vehicle)
        |> Repo.insert()
        |> case do
          {:ok, diagnostic} ->
            for part_attrs <- diagnostic_assoc_attrs[:parts] do
              case create_diagnostic_part(part_attrs, diagnostic.id) do
                {:error, diagnostic_part_error_changeset} ->
                  Repo.rollback(diagnostic_part_error_changeset)
                _ ->
                  nil
              end
            end
            Repo.preload(diagnostic, Diagnostic.all_nested_assocs)
          error ->
            error
        end
      end
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  def delete_diagnostic(%Diagnostic{} = diagnostic) do
    Repo.delete(diagnostic)
  end

  alias EasyFixApi.Orders.Budget

  def list_budgets do
    Repo.all(Budget)
    |> Repo.preload(Budget.all_nested_assocs)
  end

  def get_budget!(id) do
    Repo.get!(Budget, id)
    |> Repo.preload(Budget.all_nested_assocs)
  end

  def create_budget(attrs \\ %{}) do
    with budget_changeset = %{valid?: true} <- Budget.create_changeset(attrs),
         budget_assoc_changeset = %{valid?: true} <- Budget.assoc_changeset(attrs),
         budget_assoc_attrs <- Helpers.apply_changes_ensure_atom_keys(budget_assoc_changeset),
         diagnostic when not is_nil(diagnostic) <- Repo.get(Diagnostic, budget_assoc_attrs[:diagnostic_id]),
         issuer when not is_nil(issuer) <- Accounts.get_user_by_type_id(budget_assoc_attrs[:issuer_type], budget_assoc_attrs[:issuer_id]) do

      Repo.transaction fn ->
        budget =
          budget_changeset
          |> put_assoc(:diagnostic, diagnostic)
          |> put_assoc(:issuer, issuer)
          |> Repo.insert!()

        for part_attrs <- budget_assoc_attrs[:parts] do
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
        {:error, "diagnostic or issuer does not exist"}
    end
  end

  def update_budget(%Budget{} = budget, attrs) do
    budget
    |> Budget.changeset(attrs)
    |> Repo.update()
  end

  def delete_budget(%Budget{} = budget) do
    Repo.delete(budget)
  end

  alias EasyFixApi.Orders.BudgetPart

  def create_budget_part(attrs \\ %{}, budget_id) do
    with budget_part_changeset = %{valid?: true} <- BudgetPart.create_changeset(attrs),
         budget_part_assoc_changeset = %{valid?: true} <- BudgetPart.assoc_changeset(attrs),
         budget_part_assoc_attrs <- Helpers.apply_changes_ensure_atom_keys(budget_part_assoc_changeset) do

        part = Parts.get_part!(budget_part_assoc_attrs[:part_id])
        budget = get_budget!(budget_id)

        budget_part_changeset
        |> put_assoc(:part, part)
        |> put_assoc(:budget, budget)
        |> Repo.insert()
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  alias EasyFixApi.Orders.Order

  def list_orders do
    Repo.all(Order)
    |> Repo.preload(Order.all_nested_assocs)
  end

  def get_order!(id) do
    Repo.get!(Order, id)
    |> Repo.preload(Order.all_nested_assocs)
  end

  def create_order(attrs \\ %{}) do
    with order_changeset = %{valid?: true} <- Order.create_changeset(attrs),
         order_assoc_changeset = %{valid?: true} <- Order.assoc_changeset(attrs),
         order_assoc_attrs <- Helpers.apply_changes_ensure_atom_keys(order_assoc_changeset) do

      customer = Accounts.get_customer!(order_assoc_attrs[:customer_id])
      Repo.transaction fn ->
        {:ok, diagnostic} = create_diagnostic(order_assoc_attrs[:diagnostic])

        order_changeset
        |> put_assoc(:diagnostic, diagnostic)
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

  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

end
