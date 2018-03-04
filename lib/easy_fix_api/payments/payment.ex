defmodule EasyFixApi.Payments.Payment do
  use Ecto.Schema
  import Ecto.Changeset
  alias EasyFixApi.Payments.Payment

  schema "payments" do
    field :total_amount, :integer
    field :factoring_fee, :decimal
    field :installments, :integer
    field :iugu_fee, :decimal
    field :iugu_invoice_id, :string
    field :payment_method, :string
    field :state, :string
    field :card_brand, :string
    field :card_last_digits, :string

    belongs_to :quote, EasyFixApi.Orders.Quote
    belongs_to :order, EasyFixApi.Orders.Order
    has_many :payment_parts, EasyFixApi.Payments.PaymentPart

    field :token, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  def pending_changeset(attrs) do
    %Payment{}
    |> cast(attrs, [
      :total_amount, :installments, :token, :payment_method, :card_brand, :card_last_digits,
      :iugu_fee, :factoring_fee, :quote_id, :order_id
    ])
    |> validate_required([
      :total_amount, :installments, :token, :payment_method,
      :iugu_fee, :factoring_fee, :quote_id, :order_id
    ])
    |> validate_number(:total_amount, greater_than_or_equal_to: 1_00)
  end

  def changeset(%Payment{} = payment, attrs) do
    payment
    |> cast(attrs, [:total_amount, :installments, :state, :payment_method, :iugu_fee, :factoring_fee])
    |> validate_required([:total_amount, :installments, :payment_method, :iugu_fee, :factoring_fee])
  end

  def all_nested_assocs do
    []
  end
end
