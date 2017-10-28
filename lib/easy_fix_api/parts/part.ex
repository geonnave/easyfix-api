defmodule EasyFixApi.Parts.Part do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "parts" do
    field :name, :string
    field :repair_by_fixer, :boolean
    belongs_to :part_sub_group, EasyFixApi.Parts.PartSubGroup
    belongs_to :garage_category, EasyFixApi.Parts.GarageCategory
    many_to_many :diagnosis, EasyFixApi.Orders.Diagnosis, join_through: "diagnosis_parts"

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name, :repair_by_fixer])
  end

  def all_nested_assocs do
    [:garage_category, [part_sub_group: [part_group: :part_system]]]
  end
end
