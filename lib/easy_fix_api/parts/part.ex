defmodule EasyFixApi.Parts.Part do
  use Ecto.Schema

  schema "parts" do
    field :name, :string
    field :repair_by_fixer, :boolean
    belongs_to :part_sub_group, EasyFixApi.Parts.PartSubGroup
    belongs_to :garage_category, EasyFixApi.Parts.GarageCategory
    many_to_many :diagnosis, EasyFixApi.Orders.Diagnosis, join_through: "diagnosis_parts"

    timestamps(type: :utc_datetime)
  end

  def all_nested_assocs do
    [:garage_category, [part_sub_group: [part_group: :part_system]]]
  end
end
