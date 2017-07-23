defmodule EasyFixApi.Payments do
  @moduledoc """
  The boundary for the Payments system.
  """

  import Ecto.{Query, Changeset}, warn: false
  import EasyFixApi.Helpers
  alias EasyFixApi.Repo

  alias EasyFixApi.Payments.Bank

  def list_banks do
    Repo.all(Bank)
  end

  def get_bank!(id), do: Repo.get!(Bank, id)

  def create_bank(attrs \\ %{}) do
    %Bank{}
    |> Bank.changeset(attrs)
    |> Repo.insert()
  end

  def update_bank(%Bank{} = bank, attrs) do
    bank
    |> Bank.changeset(attrs)
    |> Repo.update()
  end

  def delete_bank(%Bank{} = bank) do
    Repo.delete(bank)
  end

  def change_bank(%Bank{} = bank) do
    Bank.changeset(bank, %{})
  end

  alias EasyFixApi.Payments.BankAccount

  def list_bank_accounts do
    Repo.all(BankAccount)
    |> Repo.preload(:bank)
  end

  def get_bank_account!(id) do
    Repo.get!(BankAccount, id)
    |> Repo.preload(:bank)
  end

  def create_bank_account(attrs \\ %{}) do
    with bank_account_changeset = %{valid?: true} <- BankAccount.create_changeset(attrs),
         bank_account_assoc_changeset = %{valid?: true} <- BankAccount.assoc_changeset(attrs),
         bank_account_assoc_attrs <- apply_changes_ensure_atom_keys(bank_account_assoc_changeset) do

      bank = get_bank!(bank_account_assoc_attrs[:bank_id])

      bank_account_changeset
      |> put_assoc(:bank, bank)
      |> Repo.insert()
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  # TODO: actually implement this
  def update_bank_account(%BankAccount{} = bank_account, attrs) do
    bank_account
    |> BankAccount.changeset(attrs)
    |> Repo.update()
  end

  def delete_bank_account(%BankAccount{} = bank_account) do
    Repo.delete(bank_account)
  end
end
