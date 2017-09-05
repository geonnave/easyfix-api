defmodule EasyFixApi.OrderStateMachineTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Orders.OrderStateMachine

  describe "started" do
    test "goes to created_with_diagnosis when receives :call_direct" do
      timeouts = %{created_with_diagnosis: 0.1}
      data = %{order_id: 1, timeouts: timeouts}

      {:ok, _} = OrderStateMachine.start_link data
      assert {:started, _} = OrderStateMachine.get_state data[:order_id]
      :ok = OrderStateMachine.call_direct data[:order_id]
      assert {:created_with_diagnosis, _} = OrderStateMachine.get_state data[:order_id]
    end
  end

  describe "created_with_diagnosis" do
    test "goes to not_budgeted_by_garages when timeout and budgets size equals to 0" do
      timeouts = %{created_with_diagnosis: 0.1}
      data = %{order_id: 1, timeouts: timeouts}
      {:ok, _} = OrderStateMachine.start_link data
      :ok = OrderStateMachine.call_direct data[:order_id]

      Process.sleep 50
      assert {:created_with_diagnosis, _} = OrderStateMachine.get_state data[:order_id]
      Process.sleep 60
      assert {:not_budgeted_by_garage, _} = OrderStateMachine.get_state data[:order_id]
    end

    test "goes to budgeted_by_garages when timeout and budgets size greater than 0" do
      timeouts = %{created_with_diagnosis: 0.1}
      data = %{order_id: 1, timeouts: timeouts}
      {:ok, _} = OrderStateMachine.start_link data
      :ok = OrderStateMachine.call_direct data[:order_id]

      Process.sleep 50
      assert {:created_with_diagnosis, _} = OrderStateMachine.get_state data[:order_id]
      # create budget
      Process.sleep 60
      assert {:budgeted_by_garage, _} = OrderStateMachine.get_state data[:order_id]
    end
  end
end
