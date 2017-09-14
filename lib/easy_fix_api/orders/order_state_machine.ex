defmodule EasyFixApi.Orders.OrderStateMachine do
  use GenStateMachine
  require Logger
  alias EasyFixApi.Orders

  def start_link(data) do
    GenStateMachine.start_link __MODULE__, data, name: name(data[:order_id])
  end

  def customer_clicked(order_id, button) do
    GenStateMachine.call name(order_id), {:customer_clicked, button}
  end
  def get_state(order_id) do
    GenStateMachine.call name(order_id), :get_state
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
    Logger.debug ":state_timeout, :to_budgeted_by_garages, :created_with_diagnosis"
    case Orders.list_budgets_by_order(data[:order_id]) do
      [] ->
        order = Orders.get_order!(data[:order_id])
        next_state_attrs = next_state_attrs(:not_budgeted_by_garages)
        case Orders.update_order_state(order, next_state_attrs) do
          {:ok, %{state: state}} ->
            {:next_state, state, data}
          {:error, changeset} ->
            {:next_state, :finished_error, put_in(data[:changeset], changeset)}
        end
      _budgets ->
        order = Orders.get_order!(data[:order_id])
        next_state_attrs = next_state_attrs(:budgeted_by_garages)
        case Orders.update_order_state(order, next_state_attrs) do
          {:ok, %{state: state, state_due_date: state_due_date}} ->
            {:next_state, state, data, [state_timeout_action(state, state_due_date)]}
          {:error, changeset} ->
            {:next_state, :finished_error, put_in(data[:changeset], changeset)}
        end
    end
  end

  def handle_event(:state_timeout, :to_budget_accepted_by_customer, :budgeted_by_garages, data) do
    Logger.debug ":state_timeout, :to_budget_accepted_by_customer, :budgeted_by_garages"
    {:next_state, :timeout, data}
  end
  def handle_event({:call, from}, {:customer_clicked, :accept_budget}, :budgeted_by_garages, data) do
    Logger.debug "{:call, from}, {:customer_clicked, :accept_budget}, :budgeted_by_garages"
    order = Orders.get_order!(data[:order_id])
    next_state_attrs = next_state_attrs(:budget_accepted_by_customer)
    case Orders.update_order_state(order, next_state_attrs) do
      {:ok, %{state: state, state_due_date: state_due_date}} ->
        reply_action = {:reply, from, :ok}
        timeout_action = state_timeout_action(state, state_due_date)
        {:next_state, state, data, [reply_action, timeout_action]}
      {:error, changeset} ->
        reply_action = {:reply, from, {:error, changeset}}
        {:next_state, :finished_error, put_in(data[:changeset], [reply_action])}
    end
  end
  def handle_event({:call, from}, {:customer_clicked, :not_accept_budget}, :budgeted_by_garages, data) do
    Logger.debug "{:call, from}, {:customer_clicked, :not_accept_budget}, :budgeted_by_garages"
    {:next_state, :budget_not_accepted_by_customer, data, [{:reply, from, :ok}]}
  end
  def handle_event({:call, from}, {:customer_clicked, event}, :budgeted_by_garages, _data) do
    Logger.debug "INVALID event: {:call, from}, {:customer_clicked, event}, :budgeted_by_garages"
    reply_action = {:reply, from, {:error, "the event #{inspect event} is invalid"}}
    {:keep_state_and_data, [reply_action]}
  end

  def handle_event({:call, from}, :get_state, state, data) do
    Logger.debug "{:call, from}, :get_state"
    {:keep_state_and_data, [{:reply, from, {state, data}}]}
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
  def next_state_attrs(state) do
    %{
      state: state,
      state_due_date: Orders.calculate_state_due_date(state)
    }
  end

  def name(order_id) do
    {:via, Registry, {Registry.OrderStateMachine, order_id}}
  end
end
