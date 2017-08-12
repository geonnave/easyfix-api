defmodule EasyFixApi.OrdersTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Orders
  alias EasyFixApi.Orders.{Diagnostic, BudgetPart, Budget}

  @invalid_attrs %{accepts_used_parts: nil, comment: nil, need_tow_truck: nil, status: nil}

  test "list_diagnostics/1 returns all diagnostics" do
    diagnostic = insert(:diagnostic)
    [listed_diag] = Orders.list_diagnostics()
    assert listed_diag.id == diagnostic.id
  end

  test "create_diagnostic/1 with valid data creates a diagnostic" do
    part1 = insert(:part)
    part2 = insert(:part)
    diagnostic_attrs =
      params_for(:diagnostic)
      |> put_in([:parts_ids], [part1.id, part2.id])

    assert {:ok, %Diagnostic{} = diagnostic} = Orders.create_diagnostic(diagnostic_attrs)
    assert diagnostic.accepts_used_parts == true
    assert diagnostic.comment == "some comment"
    assert diagnostic.need_tow_truck == true
    assert diagnostic.status == "some status"
    assert length(diagnostic.parts) == 2
  end

  test "create_diagnostic/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Orders.create_diagnostic(@invalid_attrs)
  end

  test "delete_diagnostic/1 deletes the diagnostic" do
    diagnostic = insert(:diagnostic)
    assert 2 == EasyFixApi.Parts.list_parts |> length()
    assert {:ok, %Diagnostic{}} = Orders.delete_diagnostic(diagnostic)
    assert 2 == EasyFixApi.Parts.list_parts |> length()
    assert_raise Ecto.NoResultsError, fn -> Orders.get_diagnostic!(diagnostic.id) end
  end

  test "create_budget_part/1 with valid data creates a budget_part" do
    budget = insert(:budget)
    part = insert(:part)
    budget_part_attrs =
      params_for(:budget_part)
      |> put_in([:part_id], part.id)

    {:ok, %BudgetPart{} = budget_part} = Orders.create_budget_part(budget_part_attrs, budget.id)
    assert budget_part.budget.id == budget.id
    assert budget_part.part.id == part.id
    assert budget_part.price == budget_part_attrs[:price]
    assert budget_part.quantity == budget_part_attrs[:quantity]
  end

  test "create_budget/1 with valid data creates a budget" do
    diagnostic = insert(:diagnostic)
    [part1, part2] = diagnostic.parts
    parts = [
      %{part_id: part1.id, price: 4200, quantity: 1},
      %{part_id: part2.id, price: 200, quantity: 4},
    ]

    budget_attrs =
      params_for(:budget)
      |> put_in([:parts], parts)
      |> put_in([:diagnostic_id], diagnostic.id)

    assert {:ok, %Budget{} = budget} = Orders.create_budget(budget_attrs)
    assert budget.service_cost == budget_attrs[:service_cost]
    assert length(budget.parts) == 2
    assert budget.diagnostic.id == diagnostic.id
  end
end
