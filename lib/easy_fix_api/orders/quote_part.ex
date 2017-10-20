defmodule EasyFixApi.Orders.QuotePart do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "quotes_parts" do
    belongs_to :quote, EasyFixApi.Orders.Quote
    belongs_to :part, EasyFixApi.Parts.Part, on_replace: :nilify
    field :quantity, :integer
    field :price, Money.Ecto.Type

    timestamps(type: :utc_datetime)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:quantity, :price, :part_id])
    |> validate_required([:quantity, :price, :part_id])
  end

  def update_changeset(quote_part, attrs) do
    quote_part
    |> cast(attrs, [:quantity, :price, :part_id])
  end
end
