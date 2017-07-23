defmodule EasyFixApi.Payments.Bank do
  use Ecto.Schema
  import Ecto.{Changeset}

  schema "banks" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  def changeset(bank, attrs) do
    bank
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
  end
end
