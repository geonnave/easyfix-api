defmodule EasyFixApiWeb.BankAccountControllerTest do
  use EasyFixApiWeb.ConnCase

  alias EasyFixApi.Payments
  alias EasyFixApi.Payments.BankAccount

  @create_attrs %{agency: "some agency", number: "some number"}
  @update_attrs %{agency: "some updated agency", number: "some updated number"}
  @invalid_attrs %{agency: nil, number: nil}

  def fixture(:bank_account) do
    {:ok, bank_account} = Payments.create_bank_account(@create_attrs)
    bank_account
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, bank_account_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates bank_account and renders bank_account when data is valid", %{conn: conn} do
    bank = insert(:bank)
    attrs =
      @create_attrs
      |> put_in([:bank_id], bank.id)

    conn = post conn, bank_account_path(conn, :create), bank_account: attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, bank_account_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "agency" => "some agency",
      "number" => "some number",
      "bank_name" => "Itau",
      "bank_code" => "341"}
  end

  test "does not create bank_account and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, bank_account_path(conn, :create), bank_account: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen bank_account and renders bank_account when data is valid", %{conn: conn} do
    %BankAccount{id: id} = bank_account = insert(:bank_account)

    conn = put conn, bank_account_path(conn, :update, bank_account), bank_account: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, bank_account_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "agency" => "some updated agency",
      "number" => "some updated number",
      "bank_name" => "Itau",
      "bank_code" => "341"}
  end

  test "does not update chosen bank_account and renders errors when data is invalid", %{conn: conn} do
    bank_account = insert(:bank_account)
    conn = put conn, bank_account_path(conn, :update, bank_account), bank_account: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen bank_account", %{conn: conn} do
    bank_account = insert(:bank_account)
    conn = delete conn, bank_account_path(conn, :delete, bank_account)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, bank_account_path(conn, :show, bank_account)
    end
  end
end
