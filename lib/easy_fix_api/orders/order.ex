defmodule EasyFixApi.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :state, EasyFixApi.Orders.StateEnum # this information is mostly useful to internal business logic
    field :state_meta, :string
    field :state_due_date, :utc_datetime
    field :conclusion_date, :utc_datetime
    field :rating, :integer
    field :rating_comment, :string

    has_one :diagnosis, EasyFixApi.Orders.Diagnosis
    belongs_to :customer, EasyFixApi.Accounts.Customer

    belongs_to :best_price_quote, EasyFixApi.Orders.Quote
    belongs_to :accepted_quote, EasyFixApi.Orders.Quote

    timestamps(type: :utc_datetime)
  end

  @required_attrs ~w()a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end

  def update_state_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:state, :state_due_date])
    |> validate_required([:state])
  end

  def set_accepted_quote_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:accepted_quote_id])
    |> validate_required([:accepted_quote_id])
  end
  def set_best_price_quote_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:best_price_quote_id])
    |> validate_required([:best_price_quote_id])
  end

  def set_rating_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:rating, :rating_comment])
    |> validate_required([:rating])
    |> validate_inclusion(:rating, [1, 5])
  end

  @assoc_types %{diagnosis: :map, customer_id: :integer}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end

  def all_nested_assocs do
    [
      diagnosis: [EasyFixApi.Orders.Diagnosis.all_nested_assocs],
      customer: [EasyFixApi.Accounts.Customer.all_nested_assocs],
      accepted_quote: [EasyFixApi.Orders.Quote.all_nested_assocs],
      best_price_quote: [EasyFixApi.Orders.Quote.all_nested_assocs],
    ]
  end
end
