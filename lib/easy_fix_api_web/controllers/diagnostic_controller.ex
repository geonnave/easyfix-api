defmodule EasyFixApiWeb.DiagnosticController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Orders
  alias EasyFixApi.Orders.Diagnostic

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params) do
    diagnostics = Orders.list_diagnostics()
    render(conn, "index.json", diagnostics: diagnostics)
  end

  def create(conn, %{"diagnostic" => diagnostic_params}) do
    with {:ok, %Diagnostic{} = diagnostic} <- Orders.create_diagnostic(diagnostic_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", diagnostic_path(conn, :show, diagnostic))
      |> render("show.json", diagnostic: diagnostic)
    end
  end

  def show(conn, %{"id" => id}) do
    diagnostic = Orders.get_diagnostic!(id)
    render(conn, "show.json", diagnostic: diagnostic)
  end

  def delete(conn, %{"id" => id}) do
    diagnostic = Orders.get_diagnostic!(id)
    with {:ok, %Diagnostic{}} <- Orders.delete_diagnostic(diagnostic) do
      send_resp(conn, :no_content, "")
    end
  end
end
