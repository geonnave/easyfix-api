defmodule EasyFixApiWeb.AddressControllerTest do
  use EasyFixApiWeb.ConnCase

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, address_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end
end