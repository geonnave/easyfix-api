defmodule EasyFixApi.Payments.Bank do
  use Ecto.Schema
  import Ecto.{Changeset}

  schema "banks" do
    field :code, :string
    field :name, :string
    has_many :bank_accounts, EasyFixApi.Payments.BankAccount

    timestamps()
  end

  def changeset(bank, attrs) do
    bank
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
  end
end
