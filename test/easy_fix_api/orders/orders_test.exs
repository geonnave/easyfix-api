defmodule EasyFixApi.OrdersTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Orders

  describe "diagnostics" do
    alias EasyFixApi.Orders.{Diagnostic}
    @invalid_diagnostic_attrs %{accepts_used_parts: nil, comment: nil, need_tow_truck: nil, status: nil}

    test "list_diagnostics/1 returns all diagnostics" do
      diagnostic = insert(:diagnostic)
      [listed_diag] = Orders.list_diagnostics()
      assert listed_diag.id == diagnostic.id
    end

    test "create_diagnostic/1 with valid data creates a diagnostic" do
      part1 = insert(:part)
      part2 = insert(:part)
      parts = [
        %{part_id: part1.id, quantity: 1},
        %{part_id: part2.id, quantity: 4},
      ]

      diagnostic_attrs =
        params_for(:diagnostic)
        |> put_in([:parts], parts)

      assert {:ok, %Diagnostic{} = diagnostic} = Orders.create_diagnostic(diagnostic_attrs)
      assert diagnostic.accepts_used_parts == true
      assert diagnostic.comment == "some comment"
      assert diagnostic.need_tow_truck == true
      assert diagnostic.status == "some status"
      assert length(diagnostic.parts) == 2
    end

    test "create_diagnostic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_diagnostic(@invalid_diagnostic_attrs)
    end
  end

  describe "diagnostics_parts" do
    alias EasyFixApi.Orders.{DiagnosticPart}

    test "create_diagnostic_part/2 with valid data creates a diagnostic_part" do
      diagnostic = insert(:diagnostic)
      part = insert(:part)
      diagnostic_part_attrs =
        params_for(:diagnostic_part)
        |> put_in([:part_id], part.id)

      {:ok, %DiagnosticPart{} = diagnostic_part} = Orders.create_diagnostic_part(diagnostic_part_attrs, diagnostic.id)
      assert diagnostic_part.diagnostic.id == diagnostic.id
      assert diagnostic_part.part.id == part.id
      assert diagnostic_part.quantity == diagnostic_part_attrs[:quantity]
    end
  end

  describe "budgets_parts" do
    alias EasyFixApi.Orders.{BudgetPart}

    test "create_budget_part/2 with valid data creates a budget_part" do
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
  end

  describe "budgets" do
    alias EasyFixApi.Orders.{Budget}

    test "create_budget/1 with valid data creates a budget" do
      garage = insert(:garage)
      diagnostic = insert(:diagnostic)
      %{part: part1} = diagnostic_parts_with_diagnostic(diagnostic) |> insert()
      %{part: part2} = diagnostic_parts_with_diagnostic(diagnostic) |> insert()
      parts = [
        %{part_id: part1.id, price: 4200, quantity: 1},
        %{part_id: part2.id, price: 200, quantity: 4},
      ]

      budget_attrs =
        params_for(:budget)
        |> put_in([:parts], parts)
        |> put_in([:diagnostic_id], diagnostic.id)
        |> put_in([:issuer_id], garage.id)
        |> put_in([:issuer_type], "garage")

      assert {:ok, %Budget{} = budget} = Orders.create_budget(budget_attrs)
      assert budget.service_cost == budget_attrs[:service_cost]
      assert length(budget.parts) == 2
      assert budget.diagnostic.id == diagnostic.id
      assert budget.issuer.id == garage.user.id
      assert budget.issuer_type == :garage
    end
  end

  describe "orders" do
    alias EasyFixApi.Orders.Order

    @invalid_attrs %{conclusion_date: nil, opening_date: nil, status: nil, sub_status: nil}

    test "list_orders/0 returns all orders" do
      order = insert(:order)
      [listed_order] = Orders.list_orders()
      assert listed_order.id == order.id
    end

    test "create_order/1 with valid data creates a order" do
      diagnostic_attrs =
        params_for(:diagnostic)
        |> put_in([:parts], diagnostic_parts_params(2))

      order_attrs =
        params_for(:order)
        |> put_in([:diagnostic], diagnostic_attrs)

      assert {:ok, %Order{} = order} = Orders.create_order(order_attrs)

      {:ok, opening_date, _} = DateTime.from_iso8601 order_attrs[:opening_date]
      assert order.opening_date == opening_date
      assert order.status == order_attrs[:status]
      assert order.sub_status == order_attrs[:sub_status]
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "delete_order/1 deletes the order" do
      order = insert(:order)
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end
  end
end
