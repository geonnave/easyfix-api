defmodule EasyFixApi.Application do
  use Application
  alias EasyFixApi.Orders
  alias EasyFixApi.Orders.OrderStateMachine
  require Logger

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(EasyFixApi.Repo, []),
      supervisor(EasyFixApiWeb.Endpoint, []),
      {Registry, [keys: :unique, name: Registry.OrderStateMachine]},
      worker(EasyFixApi.Orders.StateTimeouts, []),
    ]

    {:ok, pid} = Task.start(&start_state_machines/0)
    Process.send_after pid, :start_state_machines, 3000

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EasyFixApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_state_machines do
    receive do
      :start_state_machines ->
        Logger.info "Starting state machines..."
        order_states = Application.get_env(:easy_fix_api, :order_states)

        Orders.list_orders
        |> Enum.reject(& order_states[&1.state][:is_final_state])
        |> Enum.each(fn order ->
          case OrderStateMachine.start_link(order_id: order.id) do
            {:ok, _} ->
              Logger.info "Started state machine for order #{order.id}"
            _ ->
              nil
          end
        end)
    end
  end
end
