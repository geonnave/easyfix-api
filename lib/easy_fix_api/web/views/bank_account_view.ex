defmodule EasyFixApi.Web.BankAccountView do
  use EasyFixApi.Web, :view
  alias EasyFixApi.Web.BankAccountView

  def render("index.json", %{bank_accounts: bank_accounts}) do
    %{data: render_many(bank_accounts, BankAccountView, "bank_account.json")}
  end

  def render("show.json", %{bank_account: bank_account}) do
    %{data: render_one(bank_account, BankAccountView, "bank_account.json")}
  end

  def render("bank_account.json", %{bank_account: bank_account}) do
    %{id: bank_account.id,
      agency: bank_account.agency,
      number: bank_account.number,
      bank_name: bank_account.bank.name,
      bank_code: bank_account.bank.code}
  end
end
