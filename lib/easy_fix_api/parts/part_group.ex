defmodule EasyFixApi.Parts.PartGroup do
  use Ecto.Schema

  schema "part_groups" do
    field :name, :string
    belongs_to :part_system, EasyFixApi.Parts.PartSystem
    has_many :part_sub_groups, EasyFixApi.Parts.PartSubGroup

    timestamps(type: :utc_datetime)
  end
end
