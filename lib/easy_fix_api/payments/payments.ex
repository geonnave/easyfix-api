defmodule EasyFixApi.Payments do
  @moduledoc """
  The boundary for the Payments system.
  """

  import Ecto.{Query, Changeset}, warn: false
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
end
