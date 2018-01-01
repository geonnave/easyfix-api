defmodule EasyFixApi.Payments.PaymentPart do
  use Ecto.Schema
  import Ecto.Changeset
  alias EasyFixApi.Payments.PaymentPart

  schema "payment_parts" do
    field :price, :integer
    field :quantity, :integer

    belongs_to :payment, EasyFixApi.Payments.Payment
    belongs_to :part, EasyFixApi.Parts.Part, on_replace: :nilify

    timestamps(type: :utc_datetime)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(%PaymentPart{} = payment_part, attrs) do
    payment_part
    |> cast(attrs, [:quantity, :price, :part_id, :payment_id])
    |> validate_required([:quantity, :price, :part_id, :payment_id])
    |> validate_number(:quantity, [greater_than: 0])
  end
end
