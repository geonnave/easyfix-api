defmodule EasyFixApiWeb.DiagnosisReviewController do
  use EasyFixApiWeb, :controller
  alias EasyFixApi.{Orders, Parts, Repo}
  alias EasyFixApi.Orders.Order

  def index(conn, _params) do
    diagnosis =
      Orders.list_diagnosis
      |> Repo.preload([order: [Order.all_nested_assocs]])
    render conn, "index.html", diagnosis: diagnosis
  end

  def show(conn, %{"id" => id}) do
    diag = Orders.get_diagnosis!(id)
    parts = Parts.list_parts
    render conn, "show.html", diag: diag, parts: parts
  end
end
