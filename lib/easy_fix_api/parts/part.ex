defmodule EasyFixApi.Parts.Part do
  use Ecto.Schema

  schema "parts" do
    field :name, :string
    belongs_to :part_sub_group, EasyFixApi.Parts.PartSubGroup
    belongs_to :garage_category, EasyFixApi.Parts.GarageCategory
    # has_many :repair_by_fixer_parts, EasyFixApi.Business.RepairByFixerPart

    timestamps()
  end
end
