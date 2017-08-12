defmodule EasyFixApiWeb.BankAccountController do
  use EasyFixApiWeb, :controller

  alias EasyFixApi.Payments
  alias EasyFixApi.Payments.BankAccount

  action_fallback EasyFixApiWeb.FallbackController

  def index(conn, _params) do
    bank_accounts = Payments.list_bank_accounts()
    render(conn, "index.json", bank_accounts: bank_accounts)
  end

  def create(conn, %{"bank_account" => bank_account_params}) do
    with {:ok, %BankAccount{} = bank_account} <- Payments.create_bank_account(bank_account_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", bank_account_path(conn, :show, bank_account))
      |> render("show.json", bank_account: bank_account)
    end
  end

  def show(conn, %{"id" => id}) do
    bank_account = Payments.get_bank_account!(id)
    render(conn, "show.json", bank_account: bank_account)
  end

  def update(conn, %{"id" => id, "bank_account" => bank_account_params}) do
    bank_account = Payments.get_bank_account!(id)

    with {:ok, %BankAccount{} = bank_account} <- Payments.update_bank_account(bank_account, bank_account_params) do
      render(conn, "show.json", bank_account: bank_account)
    end
  end

  def delete(conn, %{"id" => id}) do
    bank_account = Payments.get_bank_account!(id)
    with {:ok, %BankAccount{}} <- Payments.delete_bank_account(bank_account) do
      send_resp(conn, :no_content, "")
    end
  end
end
