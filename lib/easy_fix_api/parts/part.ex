defmodule EasyFixApi.Parts.Part do
  use Ecto.Schema

  schema "parts" do
    field :name, :string
    belongs_to :part_sub_group, EasyFixApi.Parts.PartSubGroup
    belongs_to :garage_category, EasyFixApi.Parts.GarageCategory
    has_one :repair_by_fixer_part, EasyFixApi.Business.RepairByFixerPart
    many_to_many :diagnostics, EasyFixApi.Orders.Diagnostic, join_through: "diagnostics_parts"

    timestamps(type: :utc_datetime)
  end

  def all_nested_assocs do
    [:garage_category, [part_sub_group: [part_group: :part_system]], :repair_by_fixer_part]
  end
end
