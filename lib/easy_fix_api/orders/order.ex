defmodule EasyFixApi.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias EasyFixApi.Orders.Order


  schema "orders" do
    field :conclusion_date, :utc_datetime
    field :opening_date, :utc_datetime
    field :status, :string
    field :sub_status, :string

    timestamps()
  end

  @doc false
  def changeset(%Order{} = order, attrs) do
    order
    |> cast(attrs, [:status, :sub_status, :opening_date, :conclusion_date])
    |> validate_required([:status, :sub_status, :opening_date, :conclusion_date])
  end
end
