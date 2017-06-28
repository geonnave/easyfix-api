defmodule EasyFixApi.CarsTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Cars

  @create_attrs %{name: "some name"}
  # @update_attrs %{name: "some updated name"}
  # @invalid_attrs %{name: nil}

  def fixture(:brand, attrs \\ @create_attrs) do
    {:ok, brand} = Cars.create_brand(attrs)
    brand
  end
end
