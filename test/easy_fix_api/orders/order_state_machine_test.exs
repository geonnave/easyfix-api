defmodule EasyFixApi.OrderStateMachineTest do
  use EasyFixApi.DataCase
  import EasyFixApi.Factory

  alias EasyFixApi.Orders
  alias EasyFixApi.Orders.OrderStateMachine

  test "timeout_value/1" do
    assert 100 = OrderStateMachine.timeout_value(:created_with_diagnosis)
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

    @tag :skip
    test "goes to budgeted_by_garages when timeout and budgets size greater than 0" do
      timeouts = %{created_with_diagnosis: 0.1}
      data = %{order_id: 1, timeouts: timeouts}
      {:ok, _} = OrderStateMachine.start_link data
      :ok = OrderStateMachine.call_direct data[:order_id]

      Process.sleep half_timeout(:created_with_diagnosis)
      assert {:created_with_diagnosis, _} = OrderStateMachine.get_state data[:order_id]

      # create budget
      {budget_attrs, _garage, _order} = budget_with_all_params()
      {:ok, _budget} = Orders.create_budget(budget_attrs)

      Process.sleep gt_half_timeout(:created_with_diagnosis)
      assert {:budgeted_by_garages, _} = OrderStateMachine.get_state data[:order_id]
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
end
