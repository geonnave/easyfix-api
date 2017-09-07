defmodule EasyFixApi.Orders.OrderStateMachine do
  use GenStateMachine
  require Logger
  alias EasyFixApi.Orders

  def start_link(data) do
    GenStateMachine.start_link __MODULE__, {:started, data}, name: name(data[:order_id])
  end

  def call_direct(order_id) do
    GenStateMachine.cast name(order_id), :call_direct
  end

  def get_state(order_id) do
    GenStateMachine.call name(order_id), :get_state
  end
  def timeout(data, state) do
    round(data[:timeouts][state]*1000)
  end

  def handle_event(:cast, :call_direct, :started, data) do
    next_state = :created_with_diagnosis
    timeout = timeout(data, next_state)
    {:next_state, next_state, data,
      [{:event_timeout, timeout, :to_budgeted_by_garages}]}
  end

  def handle_event(:cast, :budgeted, :created_with_diagnosis, data) do
    {:next_state, :budgeted_by_garages, data}
  end

  def handle_event(:event_timeout, :to_budgeted_by_garages, :created_with_diagnosis, data) do
    case Orders.list_budgets_by_order(data[:order_id]) do
      [] ->
        {:next_state, :not_budgeted_by_garages, data}
      _budgets ->
        {:next_state, :budgeted_by_garages, data}
    end
  end
  def handle_event(:event_timeout, :to_budgeted_by_garages, _state, _data) do
    :keep_state_and_data
  end

  def handle_event({:call, from}, :get_state, state, data) do
    {:keep_state_and_data, [{:reply, from, {state, data}}]}
  end

  def name(order_id) do
    {:via, Registry, {Registry.OrderStateMachine, order_id}}
  end

  def order_id({_, _, {_, order_id}}), do: order_id
end
