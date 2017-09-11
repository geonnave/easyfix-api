defmodule EasyFixApi.Orders.OrderStateMachine do
  use GenStateMachine
  require Logger
  alias EasyFixApi.Orders

  def start_link(data) do
    GenStateMachine.start_link __MODULE__, data, name: name(data[:order_id])
  end

  def get_state(order_id) do
    GenStateMachine.call name(order_id), :get_state
  end

  def timeout_from_now(state_due_date) do
    Timex.diff(state_due_date, Timex.now, :milliseconds)
  end
  def timeout_value(state) do
    Application.get_env(:easy_fix_api, :order_states)[state][:timeout][:value][:milliseconds]
  end
  def timeout_event(state) do
    Application.get_env(:easy_fix_api, :order_states)[state][:timeout][:event]
  end
  def state_timeout_action(state, state_due_date) do
    {:state_timeout, timeout_from_now(state_due_date), timeout_event(state)}
  end

  def init(data) do
    case Orders.get_order!(data[:order_id]) do
      %{state: state, state_due_date: nil} ->
        {:ok, state, data}
      %{state: state, state_due_date: state_due_date} ->
        {:ok, state, data, [state_timeout_action(state, state_due_date)]}
    end
  end

  def handle_event(:state_timeout, :to_budgeted_by_garages, :created_with_diagnosis, data) do
    case Orders.list_budgets_by_order(data[:order_id]) do
      [] ->
        {:next_state, :not_budgeted_by_garages, data}
      _budgets ->
        order = Orders.get_order!(data[:order_id])
        next_state_attrs = %{
          state: :budgeted_by_garages,
          state_due_date: Orders.calculate_state_due_date(:budgeted_by_garages)
        }
        case Orders.update_order_state(order, next_state_attrs) do
          {:ok, %{state: state, state_due_date: state_due_date}} ->
            {:next_state, state, data, [state_timeout_action(state, state_due_date)]}
          {:error, changeset} ->
            {:next_state, :finished_error, put_in(data[:changeset], changeset)}
        end
    end
  end
  # def handle_event(:state_timeout, :to_budgeted_by_garages, _state, _data) do
  #   :keep_state_and_data
  # end

  def handle_event({:call, from}, :get_state, state, data) do
    {:keep_state_and_data, [{:reply, from, {state, data}}]}
  end

  def name(order_id) do
    {:via, Registry, {Registry.OrderStateMachine, order_id}}
  end

  def order_id({_, _, {_, order_id}}), do: order_id
end
