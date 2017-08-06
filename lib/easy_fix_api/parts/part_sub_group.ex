defmodule EasyFixApi.Parts.PartSubGroup do
  use Ecto.Schema

  schema "part_sub_groups" do
    field :name, :string
    belongs_to :part_group, EasyFixApi.Parts.PartGroup
    has_many :parts, EasyFixApi.Parts.Part

    timestamps(type: :utc_datetime)
  end
end
