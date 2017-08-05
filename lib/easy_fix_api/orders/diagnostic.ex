defmodule EasyFixApi.Orders.Diagnostic do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "diagnostics" do
    field :accepts_used_parts, :boolean, default: false
    field :comment, :string
    field :need_tow_truck, :boolean, default: false
    field :status, :string
    field :expiration_date, :naive_datetime

    timestamps()
  end

  @optional_attrs ~w(comment)
  @required_attrs ~w(accepts_used_parts need_tow_truck status expiration_date)a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @optional_attrs ++ @required_attrs)
    |> validate_required(@required_attrs)
  end
end
