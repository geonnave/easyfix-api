defmodule EasyFixApi.OrdersTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Orders
  alias EasyFixApi.Orders.Diagnostic

  @invalid_attrs %{accepts_used_parts: nil, comment: nil, need_tow_truck: nil, status: nil}

  test "list_diagnostics/1 returns all diagnostics" do
    diagnostic = insert(:diagnostic)
    assert Orders.list_diagnostics() == [diagnostic]
  end

  test "get_diagnostic! returns the diagnostic with given id" do
    diagnostic = insert(:diagnostic)
    assert Orders.get_diagnostic!(diagnostic.id) == diagnostic
  end

  test "create_diagnostic/1 with valid data creates a diagnostic" do
    diagnostic_attrs = params_for(:diagnostic)
    assert {:ok, %Diagnostic{} = diagnostic} = Orders.create_diagnostic(diagnostic_attrs)
    assert diagnostic.accepts_used_parts == true
    assert diagnostic.comment == "some comment"
    assert diagnostic.need_tow_truck == true
    assert diagnostic.status == "some status"
  end

  test "create_diagnostic/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Orders.create_diagnostic(@invalid_attrs)
  end

  test "delete_diagnostic/1 deletes the diagnostic" do
    diagnostic = insert(:diagnostic)
    assert {:ok, %Diagnostic{}} = Orders.delete_diagnostic(diagnostic)
    assert_raise Ecto.NoResultsError, fn -> Orders.get_diagnostic!(diagnostic.id) end
  end
end
