defmodule EasyFixApiWeb.QuoteController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Orders
  alias EasyFixApi.Orders.Quote

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params) do
    quotes = Orders.list_quotes()
    render(conn, "index.json", quotes: quotes)
  end

  def create(conn, %{"quote" => quote_params}) do
    with {:ok, %Quote{} = quote} <- Orders.create_quote(quote_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", quote_path(conn, :show, quote))
      |> render("show.json", quote: quote)
    end
  end

  def show(conn, %{"id" => id}) do
    quote = Orders.get_quote!(id)
    render(conn, "show.json", quote: quote)
  end

  def update(conn, %{"id" => id, "quote" => quote_params}) do
    quote = Orders.get_quote!(id)

    with {:ok, %Quote{} = quote} <- Orders.update_quote(quote, quote_params) do
      render(conn, "show.json", quote: quote)
    end
  end

  def delete(conn, %{"id" => id}) do
    quote = Orders.get_quote!(id)
    with {:ok, %Quote{}} <- Orders.delete_quote(quote) do
      send_resp(conn, :no_content, "")
    end
  end
end
