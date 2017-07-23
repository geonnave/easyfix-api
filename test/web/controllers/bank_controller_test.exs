defmodule EasyFixApi.Web.BankControllerTest do
  use EasyFixApi.Web.ConnCase

  alias EasyFixApi.Payments

  @create_attrs %{code: "some code", name: "some name"}

  def fixture(:bank) do
    {:ok, bank} = Payments.create_bank(@create_attrs)
    bank
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, bank_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end
end
