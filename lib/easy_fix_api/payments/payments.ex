defmodule EasyFixApi.Payments do
  @moduledoc """
  The boundary for the Payments system.
  """

  import Ecto.{Query, Changeset}, warn: false
  import EasyFixApi.Helpers
  alias EasyFixApi.{Repo, Orders, Parts, Iugu}

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

  alias EasyFixApi.Payments.Payment

  def list_payments do
    Repo.all(Payment)
    |> Repo.preload(Payment.all_nested_assocs)
  end

  def get_payment!(id) do
    Repo.get!(Payment, id)
    |> Repo.preload(Payment.all_nested_assocs)
  end

  def create_payment(attrs \\ %{}, customer_id) do
    with pending_changeset = %{valid?: true} <- Payment.pending_changeset(attrs),
         order when not is_nil(order) <- Orders.get_order_for_quote(pending_changeset.changes[:quote_id]),
         :ok <- check_customer_id(customer_id, order),
         {:ok, invoice_id} <- Iugu.charge(pending_changeset, order) do
      pending_changeset
      |> put_change(:iugu_invoice_id, invoice_id)
      |> put_change(:state, "success")
      |> Repo.insert
    else
      pending_changeset = %{valid?: false} ->
        {:error, pending_changeset}
      {:error, iugu_resp_body} ->
        {:error, iugu_resp_body}
      nil ->
        {:error, "order not found for quote_id"}
    end
  end

  def check_customer_id(same_id, %{customer: %{id: same_id}}), do: :ok
  def check_customer_id(id1, %{customer: %{id: id2}}), do: {:error, "customer id mismatch (#{id1} != #{id2})"}

  def create_pending_payment(attrs \\ %{}) do
    %Payment{}
    |> Payment.changeset(attrs)
    |> Repo.insert()
  end

  def delete_payment(%Payment{} = payment) do
    Repo.delete(payment)
  end

  def change_payment(%Payment{} = payment) do
    Payment.changeset(payment, %{})
  end


  alias EasyFixApi.Payments.PaymentPart

  def list_payment_parts do
    Repo.all(PaymentPart)
  end

  def get_payment_part!(id), do: Repo.get!(PaymentPart, id)

  def create_payment_part(attrs \\ %{}, payment_id) do
    with payment_part_changeset = %{valid?: true} <- PaymentPart.create_changeset(attrs) do
        payment = get_payment!(payment_id)
        part = Parts.get_part!(payment_part_changeset.changes[:part_id])

        payment_part_changeset
        |> put_assoc(:part, part)
        |> put_assoc(:payment, payment)
        |> Repo.insert()
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  def update_payment_part(%PaymentPart{} = payment_part, attrs) do
    payment_part
    |> PaymentPart.changeset(attrs)
    |> Repo.update()
  end

  def delete_payment_part(%PaymentPart{} = payment_part) do
    Repo.delete(payment_part)
  end

  def change_payment_part(%PaymentPart{} = payment_part) do
    PaymentPart.changeset(payment_part, %{})
  end
end
