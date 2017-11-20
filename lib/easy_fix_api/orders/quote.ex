defmodule EasyFixApi.Orders.Quote do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "quotes" do
    field :state, :string
    field :service_cost, Money.Ecto.Type
    field :due_date, :utc_datetime
    field :conclusion_date, :utc_datetime
    field :comment, :string

    field :issuer_type, EasyFixApi.Accounts.UserTypeEnum
    belongs_to :issuer, EasyFixApi.Accounts.User

    has_many :quotes_parts, EasyFixApi.Orders.QuotePart, on_delete: :delete_all, on_replace: :nilify
    belongs_to :diagnosis, EasyFixApi.Orders.Diagnosis

    field :parts, {:array, :map}, virtual: true
    field :total_amount, Money.Ecto.Type, virtual: true
    field :is_best_price, :boolean, virtual: true

    timestamps(type: :utc_datetime)
  end

  @optional_attrs ~w(due_date state comment)
  @required_attrs ~w(service_cost)a
  @assoc_attrs ~w(diagnosis_id issuer_id issuer_type parts)a

  def changeset(quote, attrs) do
    quote
    |> cast(attrs, @optional_attrs ++ @required_attrs ++ @assoc_attrs)
    |> validate_required(@required_attrs ++ @assoc_attrs)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def update_changeset(quote, attrs) do
    quote
    |> cast(attrs, [:service_cost, :parts, :comment])
  end

  def all_nested_assocs do
    [
      quotes_parts: [part: EasyFixApi.Parts.Part.all_nested_assocs],
      diagnosis: [],
      issuer: [:garage]
    ]
  end
end
