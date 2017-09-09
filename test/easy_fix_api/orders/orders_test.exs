defmodule EasyFixApi.OrdersTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Orders

  describe "diagnosis" do
    alias EasyFixApi.Orders.{Diagnosis}
    @invalid_diagnosis_attrs %{accepts_used_parts: nil, comment: nil, need_tow_truck: nil, status: nil}

    test "list_diagnosis/1 returns all diagnosis" do
      diagnosis = insert(:diagnosis)
      [listed_diag] = Orders.list_diagnosis()
      assert listed_diag.id == diagnosis.id
    end

    test "create_diagnosis/1 with valid data creates a diagnosis" do
      vehicle = insert(:vehicle_with_model)
      diagnosis_attrs = diagnosis_with_diagnosis_parts_params(vehicle.id)

      assert {:ok, %Diagnosis{} = diagnosis} = Orders.create_diagnosis(diagnosis_attrs)
      assert diagnosis.accepts_used_parts == true
      assert diagnosis.comment == "some comment"
      assert diagnosis.need_tow_truck == true
      assert diagnosis.status == "some status"
      assert length(diagnosis.parts) == 2
      assert diagnosis.vehicle.id == diagnosis_attrs[:vehicle_id]
    end

    test "create_diagnosis/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_diagnosis(@invalid_diagnosis_attrs)
    end
  end

  describe "diagnosis_parts" do
    alias EasyFixApi.Orders.{DiagnosisPart}

    test "create_diagnosis_part/2 with valid data creates a diagnosis_part" do
      diagnosis = insert(:diagnosis)
      part = insert(:part)
      diagnosis_part_attrs =
        params_for(:diagnosis_part)
        |> put_in([:part_id], part.id)

      {:ok, %DiagnosisPart{} = diagnosis_part} = Orders.create_diagnosis_part(diagnosis_part_attrs, diagnosis.id)
      assert diagnosis_part.diagnosis.id == diagnosis.id
      assert diagnosis_part.part.id == part.id
      assert diagnosis_part.quantity == diagnosis_part_attrs[:quantity]
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
      diagnosis = insert(:diagnosis)
      %{part: part1} = diagnosis_parts_with_diagnosis(diagnosis) |> insert()
      %{part: part2} = diagnosis_parts_with_diagnosis(diagnosis) |> insert()
      parts = [
        %{part_id: part1.id, price: 4200, quantity: 1},
        %{part_id: part2.id, price: 200, quantity: 4},
      ]

      budget_attrs =
        params_for(:budget)
        |> put_in([:parts], parts)
        |> put_in([:diagnosis_id], diagnosis.id)
        |> put_in([:issuer_id], garage.id)
        |> put_in([:issuer_type], "garage")

      assert {:ok, %Budget{} = budget} = Orders.create_budget(budget_attrs)
      assert budget.service_cost == budget_attrs[:service_cost]
      assert length(budget.parts) == 2
      assert budget.diagnosis.id == diagnosis.id
      assert budget.issuer.id == garage.user.id
      assert budget.issuer_type == :garage
    end

    test "list_budgets_by_order" do
      {budget_attrs, _garage, order} = budget_with_all_params()
      assert {:ok, budget} = Orders.create_budget(budget_attrs)

      [a_budget] = Orders.list_budgets_by_order(order.id)
      assert a_budget.id == budget.id
      assert [] == Orders.list_budgets_by_order(0)
    end

    test "get_budget_for_garage_order" do
      {budget_attrs, garage, order} = budget_with_all_params()
      assert {:ok, budget} = Orders.create_budget(budget_attrs)

      {:ok, the_budget} = Orders.get_budget_for_garage_order(garage.id, order.id)
      assert the_budget.id == budget.id
      assert {:error, _} = Orders.get_budget_for_garage_order(0, order.id)
      assert {:error, _} = Orders.get_budget_for_garage_order(garage.id, 0)
    end

    def budget_with_all_params do
      garage = insert(:garage)
      customer = insert(:customer)
      [vehicle] = customer.vehicles
      order_attrs = order_with_all_params(customer.id, vehicle.id)
      {:ok, order} = Orders.create_order_with_diagnosis(order_attrs)

      budget_attrs =
        params_for(:budget)
        |> put_in([:parts], parts_for_budget())
        |> put_in([:diagnosis_id], order.diagnosis.id)
        |> put_in([:issuer_id], garage.id)
        |> put_in([:issuer_type], "garage")

      {budget_attrs, garage, order}
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

    test "create_order_with_diagnosis/1 with valid data creates a order" do
      customer = insert(:customer)
      [vehicle] = customer.vehicles
      order_attrs = order_with_all_params(customer.id, vehicle.id)

      assert {:ok, %Order{} = order} = Orders.create_order_with_diagnosis(order_attrs)

      {:ok, opening_date, _} = DateTime.from_iso8601 order_attrs[:opening_date]
      assert order.opening_date == opening_date
      assert order.status == order_attrs[:status]
      assert order.sub_status == order_attrs[:sub_status]
      assert order.customer.id == order_attrs[:customer_id]
    end

    test "create_order_with_diagnosis/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order_with_diagnosis(@invalid_attrs)
    end

    test "delete_order/1 deletes the order" do
      order = insert(:order)
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end

    test "list_customer_orders/1 returns the corresponding orders" do
      customer = insert(:customer)
      [vehicle] = customer.vehicles
      order_attrs = order_with_all_params(customer.id, vehicle.id)
      {:ok, order} = Orders.create_order_with_diagnosis(order_attrs)

      assert [a_order] = Orders.list_customer_orders(customer.id)
      assert a_order.id == order.id
      assert [] = Orders.list_customer_orders(0)
    end
    test "get_customer_order/1 returns the corresponding orders" do
      customer = insert(:customer)
      [vehicle] = customer.vehicles
      order_attrs = order_with_all_params(customer.id, vehicle.id)
      {:ok, order} = Orders.create_order_with_diagnosis(order_attrs)

      assert {:ok, the_order} = Orders.get_customer_order(customer.id, order.id)
      assert the_order.id == order.id
      assert the_order.customer_id == customer.id
      assert {:error, _} = Orders.get_customer_order(customer.id, 0)
      assert {:error, _} = Orders.get_customer_order(0, order.id)
    end
  end
end
