defmodule EasyFixApi.Orders.DiagnosisPart do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "diagnosis_parts" do
    belongs_to :diagnosis, EasyFixApi.Orders.Diagnosis
    belongs_to :part, EasyFixApi.Parts.Part
    field :quantity, :integer

    timestamps(type: :utc_datetime)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:quantity, :part_id])
    |> validate_required([:quantity, :part_id])
  end

  def update_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:quantity, :part_id])
  end
end
