defmodule EasyFixApi.Orders.DiagnosisPart do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "diagnosis_parts" do
    belongs_to :diagnosis, EasyFixApi.Orders.Diagnosis
    belongs_to :part, EasyFixApi.Parts.Part
    field :quantity, :integer

    timestamps(type: :utc_datetime)
  end

  @required_attrs ~w(quantity)a

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end

  @assoc_types %{part_id: :integer}
  def assoc_changeset(attrs) do
    {attrs, @assoc_types}
    |> cast(attrs, Map.keys(@assoc_types))
    |> validate_required(Map.keys(@assoc_types))
  end
end
