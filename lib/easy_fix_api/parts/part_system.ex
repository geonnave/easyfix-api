defmodule EasyFixApi.Parts.PartSystem do
  use Ecto.Schema

  schema "part_systems" do
    field :name, :string
    has_many :part_groups, EasyFixApi.Parts.PartGroup

    timestamps(type: :utc_datetime)
  end
end
