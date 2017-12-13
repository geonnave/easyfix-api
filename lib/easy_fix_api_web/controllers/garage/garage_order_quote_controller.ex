defmodule EasyFixApiWeb.GarageOrderQuoteController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.{Orders, GarageOrders}
  alias EasyFixApi.CustomerNotifications

  action_fallback EasyFixApiWeb.FallbackController

  def create(conn, _params = %{"quote" => quote_params, "garage_id" => garage_id, "order_id" => order_id}) do
    order = Orders.get_order!(order_id)

    quote_params =
      quote_params
      |> put_in(["diagnosis_id"], order.diagnosis.id)
      |> put_in(["issuer_id"], garage_id)
      |> put_in(["issuer_type"], "garage")

    with :created_with_diagnosis <- order.state,
         {:ok, quote} <- Orders.create_quote(quote_params) do
      if Orders.is_best_price_quote(order, quote.id) do
        CustomerNotifications.new_best_quote_arrived(order, [:sms])
      end

      conn
      |> put_status(:created)
      |> render(EasyFixApiWeb.QuoteView, "show.json", quote: quote)
    else
      err = {:error, _} ->
        err
      state ->
        {:error, "cannot create quote at order state #{state}"}
    end
  end

  def show(conn, %{"garage_id" => garage_id, "order_id" => order_id}) do
    with {:ok, quote} <- Orders.get_quote_for_garage_order(garage_id, order_id) do
      render(conn, EasyFixApiWeb.QuoteView, "show.json", quote: quote)
    else
      {:error, error} ->
        render(conn, EasyFixApiWeb.ErrorView, "error.json", error: error)
    end
  end

  def update(conn, %{"quote" => quote_params, "garage_id" => garage_id, "order_id" => order_id}) do
    %{order: _order, quote: quote} = GarageOrders.get_order(garage_id, order_id)

    with {:ok, quote} <- Orders.update_quote(quote, quote_params) do
      render(conn, EasyFixApiWeb.QuoteView, "show.json", quote: quote)
    end
  end
end
