defmodule EasyFixApi.OrderStateMachineTest do
  use EasyFixApi.DataCase
  import EasyFixApi.Factory

  alias EasyFixApi.Orders
  alias EasyFixApi.Orders.OrderStateMachine

  test "timeout_value/1" do
    assert 200 = OrderStateMachine.timeout_value(:created_with_diagnosis)
  end
  test "timeout_from_now/1" do
    state_due_date = Orders.calculate_state_due_date(:created_with_diagnosis)
    assert Timex.compare(Timex.now, state_due_date) == -1
    timeout_from_now = OrderStateMachine.timeout_from_now(state_due_date)
    assert timeout_from_now > 0

    state_due_date = Orders.calculate_state_due_date(:finished_by_garage)
    assert is_nil(state_due_date)
  end

  describe "created_with_diagnosis" do
    test "start_link after create_order_with_diagnosis initializes to created_with_diagnosis" do
      order = create_order_with_diagnosis()
      data = %{order_id: order.id}
      {:ok, _} = OrderStateMachine.start_link data
      assert {:created_with_diagnosis, _} = OrderStateMachine.get_state data[:order_id]
    end

    test "goes to not_budgeted_by_garages when timeout and budgets size equals to 0" do
      order = create_order_with_diagnosis()
      data = %{order_id: order.id}
      {:ok, _} = OrderStateMachine.start_link data
      assert {:created_with_diagnosis, _} = OrderStateMachine.get_state data[:order_id]

      Process.sleep half_timeout(:created_with_diagnosis)
      assert {:created_with_diagnosis, _} = OrderStateMachine.get_state data[:order_id]
      Process.sleep gt_half_timeout(:created_with_diagnosis)
      assert {:not_budgeted_by_garages, _} = OrderStateMachine.get_state data[:order_id]
    end

    test "goes to budgeted_by_garages when timeout and budgets size greater than 0" do
      order = create_order_with_diagnosis()
      data = %{order_id: order.id}
      {:ok, _} = OrderStateMachine.start_link data

      Process.sleep half_timeout(:created_with_diagnosis)
      assert {:created_with_diagnosis, _} = OrderStateMachine.get_state data[:order_id]

      # create budget for that order
      {_budget, _garage} = create_budget_for_order(order)

      Process.sleep gt_half_timeout(:created_with_diagnosis)
      assert {:budgeted_by_garages, _} = OrderStateMachine.get_state data[:order_id]
    end
  end

  describe "budgeted_by_garages" do
    test "start_link can initialize at budgeted_by_garages" do
      order =
        create_order_with_diagnosis()
        |> update_order_state(:budgeted_by_garages)

      data = %{order_id: order.id}
      {:ok, _} = OrderStateMachine.start_link data
      assert {:budgeted_by_garages, _} = OrderStateMachine.get_state data[:order_id]
    end
    def order_at_budgeted_by_garages do
      order =
        create_order_with_diagnosis()
        |> update_order_state(:budgeted_by_garages)
      %{order_id: order.id}
    end

    test "goes to timeout when timeout" do
      data = order_at_budgeted_by_garages()
      {:ok, _} = OrderStateMachine.start_link data

      Process.sleep gt_timeout(:budgeted_by_garages)
      assert {:timeout, _} = OrderStateMachine.get_state data[:order_id]
    end
    test "goes to budget_accepted_by_customer when customer_clicked_accept_budget" do
      data = order_at_budgeted_by_garages()
      {:ok, _} = OrderStateMachine.start_link data

      OrderStateMachine.customer_clicked data[:order_id], :accept_budget
      assert {:budget_accepted_by_customer, _} = OrderStateMachine.get_state data[:order_id]
    end
    test "goes to budget_accepted_by_customer when customer_clicked not_accept_budget" do
      data = order_at_budgeted_by_garages()
      {:ok, _} = OrderStateMachine.start_link data

      OrderStateMachine.customer_clicked data[:order_id], :not_accept_budget
      assert {:budget_not_accepted_by_customer, _} = OrderStateMachine.get_state data[:order_id]
    end
  end

  def gt_timeout(state), do: OrderStateMachine.timeout_value(state) + 10
  def half_timeout(state), do: round(OrderStateMachine.timeout_value(state) / 2)
  def gt_half_timeout(state), do: round(OrderStateMachine.timeout_value(state) / 2) + 10

  def create_order_with_diagnosis do
    customer = insert(:customer)
    [vehicle] = customer.vehicles
    order_attrs = order_with_all_params(customer.id, vehicle.id)
    {:ok, order} = Orders.create_order_with_diagnosis(order_attrs)
    order
  end

  def create_budget_for_order(order) do
    garage = insert(:garage)
    budget =
      params_for(:budget)
      |> put_in([:parts], parts_for_budget())
      |> put_in([:diagnosis_id], order.diagnosis.id)
      |> put_in([:issuer_id], garage.id)
      |> put_in([:issuer_type], "garage")
      |> Orders.create_budget

    {budget, garage}
  end

  def update_order_state(order, state) do
    next_state_attrs = %{
      state: state,
      state_due_date: Orders.calculate_state_due_date(state)
    }
    {:ok, order} = Orders.update_order_state(order, next_state_attrs)
    order
  end
end
