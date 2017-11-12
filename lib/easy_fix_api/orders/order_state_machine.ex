defmodule EasyFixApi.Orders.OrderStateMachine do
  use GenStateMachine
  require Logger
  alias EasyFixApi.{Orders, CustomerOrders, Emails, Mailer, Repo}
  alias EasyFixApi.Accounts.Customer
  alias EasyFixApi.Orders.Quote

  # Public API functions

  def start_link(data) do
    GenStateMachine.start_link __MODULE__, data, name: name(data[:order_id])
  end

  def customer_clicked(order_id, event, attrs) do
    GenStateMachine.call name(order_id), {:customer_clicked, event, attrs}
  end

  def get_state(order_id) do
    GenStateMachine.call name(order_id), :get_state
  end

  # Callback functions
  def init(data) do
    case Orders.get_order!(data[:order_id]) do
      %{state: state, state_due_date: nil} ->
        {:ok, state, data}
      %{state: state, state_due_date: state_due_date} ->
        {:ok, state, data, [state_timeout_action(state, state_due_date)]}
    end
  end

  def handle_event(:state_timeout, :to_quoted_by_garages, :created_with_diagnosis, data) do
    Logger.warn ":state_timeout, :to_quoted_by_garages, :created_with_diagnosis"
    case Orders.list_quotes_by_order(data[:order_id]) do
      [] ->
        order = Orders.get_order!(data[:order_id])
        next_state_attrs = next_state_attrs(:not_quoted_by_garages)
        case Orders.update_order_state(order, next_state_attrs) do
          {:ok, %{state: state}} ->
            {:next_state, state, data}
          {:error, changeset} ->
            {:next_state, :finished_error, put_in(data[:changeset], changeset)}
        end
      quotes ->
        order = Orders.get_order!(data[:order_id])
        %{best_price_quote: best_price_quote} = CustomerOrders.generate_customer_quotes_stats(quotes)

        next_state_attrs = next_state_attrs(:quoted_by_garages)
        best_price_attrs = %{best_price_quote_id: best_price_quote.id}

        with {:ok, updated_order} <- Orders.update_order_state(order, next_state_attrs),
             {:ok, updated_order} <- Orders.set_order_best_price_quote(updated_order, best_price_attrs) do
          %{state: state, state_due_date: state_due_date} = updated_order
          Emails.quoted_by_garages(order)
          |> Mailer.deliver_later

          {:next_state, state, data, [state_timeout_action(state, state_due_date)]}
        else
          {:error, changeset} ->
            {:next_state, :finished_error, put_in(data[:changeset], changeset)}
        end
    end
  end
  def handle_event({:call, from}, {:customer_clicked, :accept_quote, attrs}, :created_with_diagnosis, data) do
    handle_clicked_accept_quote(from, attrs, data)
  end

  def handle_event(:state_timeout, :to_quote_accepted_by_customer, :quoted_by_garages, data) do
    Logger.warn ":state_timeout, :to_quote_accepted_by_customer, :quoted_by_garages"

    next_state_attrs = next_state_attrs(:timeout)
    {:ok, _updated_order} =
      data[:order_id]
      |> Orders.get_order!
      |> Orders.update_order_state(next_state_attrs)

    {:next_state, :timeout, data}
  end
  def handle_event({:call, from}, {:customer_clicked, :accept_quote, attrs}, :quoted_by_garages, data) do
    handle_clicked_accept_quote(from, attrs, data)
  end
  def handle_event({:call, from}, {:customer_clicked, :not_accept_quote, attrs}, :quoted_by_garages, data) do
    Logger.debug "{:call, from}, {:customer_clicked, :not_accept_quote, #{inspect attrs}}, :quoted_by_garages"

    next_state_attrs = next_state_attrs(:quote_not_accepted_by_customer)
    reply = {:ok, _updated_order} =
      data[:order_id]
      |> Orders.get_order!
      |> Orders.update_order_state(next_state_attrs)

    {:next_state, :quote_not_accepted_by_customer, data, [{:reply, from, reply}]}
  end
  def handle_event({:call, from}, {:customer_clicked, event, attrs}, :quoted_by_garages, _data) do
    Logger.warn "ignoring event: {:call, from}, {:customer_clicked, #{event}, #{inspect attrs}}, :quoted_by_garages"
    reply_action = {:reply, from, {:error, "invalid event #{inspect event}"}}
    {:keep_state_and_data, [reply_action]}
  end
  def handle_event({:call, from}, {:customer_clicked, event, attrs}, state, _data) do
    Logger.warn "ignoring event {:call, _from}, {:customer_clicked, #{event}, #{inspect attrs}}, #{inspect state}"
    {:keep_state_and_data, [{:reply, from, {:error, "invalid event #{inspect event} for state #{state}"}}]}
  end

  def handle_event(:state_timeout, :to_finish_by_garage, :quote_accepted_by_customer, _data) do
    # TODO: we not handling any scenario after the customer had paid us
    # we need to fix that for next releases.
    Logger.warn "ignoring event :state_timeout, :to_finish_by_garage, :quote_accepted_by_customer"
    :keep_state_and_data
  end

  def handle_event({:call, from}, :get_state, state, data) do
    Logger.debug "{:call, from}, :get_state"
    {:keep_state_and_data, [{:reply, from, {state, data}}]}
  end

  def handle_event(event_type, event, state, data) do
    Logger.warn "ignoring unknown event #{inspect({event_type, event, state, data})}"
    :keep_state_and_data
  end

  # Helper functions

  def handle_clicked_accept_quote(from, attrs, data) do
    Logger.debug "{:call, from}, {:customer_clicked, :accept_quote, #{inspect attrs}}, :quoted_by_garages"
    next_state_attrs = next_state_attrs(:quote_accepted_by_customer)
    order = Orders.get_order!(data[:order_id])
    with {:ok, updated_order} <- Orders.update_order_state(order, next_state_attrs),
         {:ok, updated_order} <- Orders.set_order_accepted_quote(updated_order, attrs) do
      updated_order
      |> Repo.preload([accepted_quote: [Quote.all_nested_assocs], customer: [Customer.all_nested_assocs]])
      |> Emails.accepted_by_customer
      |> Mailer.deliver_later

      %{state: state, state_due_date: state_due_date} = updated_order
      reply_action = {:reply, from, {:ok, updated_order}}
      timeout_action = state_timeout_action(state, state_due_date)
      {:next_state, state, data, [reply_action, timeout_action]}
    else
      {:error, changeset} ->
        reply_action = {:reply, from, {:error, changeset}}
        {:next_state, :finished_error, put_in(data[:changeset], [reply_action])}
    end
  end

  def timeout_from_now(state_due_date) do
    Timex.diff(state_due_date, Timex.now, :milliseconds)
  end

  def timeout_value(state) do
    EasyFixApi.Orders.StateTimeouts.get()[state][:timeout][:value][:milliseconds]
  end

  def timeout_event(state) do
    EasyFixApi.Orders.StateTimeouts.get()[state][:timeout][:event]
  end

  def calculate_due_date_from_now(time_span) do
    Timex.now |> Timex.shift(time_span)
  end

  def calculate_state_due_date(state) do
    case EasyFixApi.Orders.StateTimeouts.get()[state][:timeout] do
      nil ->
        nil
      timeout_data ->
        calculate_due_date_from_now(timeout_data[:value])
    end
  end

  def state_timeout_action(state, state_due_date) do
    # the timeout can be negative if the machine's state is being initialized
    # from pre-existing state (e.g. from the database, after a crash or a update with downtime)
    if (t = timeout_from_now(state_due_date)) > 0 do
      {:state_timeout, t, timeout_event(state)}
    else
      {:state_timeout, 1, timeout_event(state)}
    end
  end

  def next_state_attrs(state) do
    %{
      state: state,
      state_due_date: calculate_state_due_date(state)
    }
  end

  def name(order_id) do
    {:via, Registry, {Registry.OrderStateMachine, order_id}}
  end
end
