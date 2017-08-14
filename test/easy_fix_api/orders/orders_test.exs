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
      assert {:error, %Ecto.Changeset{}} = Orders.create_diagnostic(@invalid_diagnostic_attrs)
    end

    test "delete_diagnostic/1 deletes the diagnostic" do
      diagnostic = insert(:diagnostic)
      assert 2 == EasyFixApi.Parts.list_parts |> length()
      assert {:ok, %Diagnostic{}} = Orders.delete_diagnostic(diagnostic)
      assert 2 == EasyFixApi.Parts.list_parts |> length()
      assert_raise Ecto.NoResultsError, fn -> Orders.get_diagnostic!(diagnostic.id) end
    end
  end

  describe "budgets_parts" do
    alias EasyFixApi.Orders.{BudgetPart}

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
  end

  describe "budgets" do
    alias EasyFixApi.Orders.{Budget}

    test "create_budget/1 with valid data creates a budget" do
      garage = insert(:garage)
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

    @valid_attrs %{conclusion_date: "2010-04-17 14:00:00.000000Z", opening_date: "2010-04-17 14:00:00.000000Z", status: "some status", sub_status: "some sub_status"}
    @update_attrs %{conclusion_date: "2011-05-18 15:01:01.000000Z", opening_date: "2011-05-18 15:01:01.000000Z", status: "some updated status", sub_status: "some updated sub_status"}
    @invalid_attrs %{conclusion_date: nil, opening_date: nil, status: nil, sub_status: nil}

    def order_fixture(attrs \\ %{}) do
      {:ok, order} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Orders.create_order()

      order
    end

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Orders.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Orders.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      assert {:ok, %Order{} = order} = Orders.create_order(@valid_attrs)
      assert order.conclusion_date == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert order.opening_date == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert order.status == "some status"
      assert order.sub_status == "some sub_status"
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      assert {:ok, order} = Orders.update_order(order, @update_attrs)
      assert %Order{} = order
      assert order.conclusion_date == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert order.opening_date == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert order.status == "some updated status"
      assert order.sub_status == "some updated sub_status"
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(order, @invalid_attrs)
      assert order == Orders.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Orders.change_order(order)
    end
  end
end
