defmodule EasyFixApi.PartsTest do
  use EasyFixApi.DataCase
  alias EasyFixApi.{Parts}
  alias EasyFixApi.Parts.{Part}

  test "create_part/3 with assocs" do
    part_sub_group = insert(:part_sub_group)
    garage_category = insert(:garage_category)

    name = "Troca por pneu novo"
    attrs = %{name: name, repair_by_fixer: true}
    assert {:ok, %Part{} = part} = Parts.create_part attrs, part_sub_group, garage_category
    assert part.name == name
  end

  test "create_part/3 returns error with empty attrs" do
    part_sub_group = insert(:part_sub_group)
    garage_category = insert(:garage_category)

    attrs = %{name: "", repair_by_fixer: nil}
    assert {:error, _changeset} = Parts.create_part attrs, part_sub_group, garage_category
  end
end
