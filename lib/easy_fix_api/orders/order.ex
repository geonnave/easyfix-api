defmodule EasyFixApi.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias EasyFixApi.Orders.Order

  schema "orders" do
    field :status, :string
    field :sub_status, :string
    field :opening_date, :utc_datetime
    field :conclusion_date, :utc_datetime

    belongs_to :diagnostic, EasyFixApi.Orders.Diagnostic

    timestamps(type: :utc_datetime)
  end

  @required_attrs ~w(status sub_status opening_date)a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end

  @assoc_types %{diagnostic: :map}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end

  def all_nested_assocs do
    [
      diagnostic: [EasyFixApi.Orders.Diagnostic.all_nested_assocs]
    ]
  end
end
