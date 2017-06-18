defmodule EasyFixApi.Business.RepairByFixerPart do
  use Ecto.Schema

  schema "repair_by_fixer_parts" do
    belongs_to :part, EasyFixApi.Parts.Part

    timestamps()
  end
end
