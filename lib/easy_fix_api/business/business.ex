defmodule EasyFixApi.Business do
  @moduledoc """
  The boundary for the Business system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.Repo

  alias EasyFixApi.Business.RepairByFixerPart

  def list_repair_by_fixer_parts do
    Repo.all(RepairByFixerPart)
  end

  def get_repair_by_fixer_part!(id), do: Repo.get!(RepairByFixerPart, id)

  def change_repair_by_fixer_part(%RepairByFixerPart{} = repair_by_fixer_part) do
    repair_by_fixer_part_changeset(repair_by_fixer_part, %{})
  end

  defp repair_by_fixer_part_changeset(%RepairByFixerPart{} = repair_by_fixer_part, attrs) do
    repair_by_fixer_part
    |> cast(attrs, [])
    |> validate_required([])
  end
end
