defmodule EasyFixApi.Orders.StateTimeouts do
  use Agent
  alias EasyFixApi.{Orders, Accounts}

  def start_link do
    Agent.start_link(fn -> Application.get_env(:easy_fix_api, :order_states) end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, & &1)
  end
end
