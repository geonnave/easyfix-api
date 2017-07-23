defmodule EasyFixApi.Payments.BankAccount do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bank_accounts" do
    field :agency, :string
    field :number, :string
    belongs_to :bank, EasyFixApi.Payments.Bank
    has_one :garage, EasyFixApi.Accounts.Garage

    timestamps()
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(bank_account, attrs) do
    bank_account
    |> cast(attrs, [:agency, :number])
    |> validate_required([:agency, :number])
  end

  @assoc_types %{bank_id: :integer}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end
end
