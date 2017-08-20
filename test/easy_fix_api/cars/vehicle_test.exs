defmodule EasyFixApi.CarsTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Cars
  alias EasyFixApi.Cars.Vehicle

  @update_attrs %{model_year: "some updated model_year", plate: "some updated plate", production_year: "some updated production_year"}
  @invalid_attrs %{model_year: nil, plate: nil, production_year: nil}

  test "list_vehicle/0 returns all vehicle" do
    insert(:vehicle)
    assert length(Cars.list_vehicle()) == 1
  end

  test "get_vehicle!/1 returns the vehicle with given id" do
    vehicle = insert(:vehicle)
    assert Cars.get_vehicle!(vehicle.id).id == vehicle.id
  end

  test "create_vehicle/1 with valid data creates a vehicle" do
    vehicle_attrs = vehicle_with_all_params()

    assert {:ok, %Vehicle{} = vehicle} = Cars.create_vehicle(vehicle_attrs)
    assert vehicle.model_year == vehicle_attrs[:model_year]
    assert vehicle.plate == String.upcase(vehicle_attrs[:plate])
    assert vehicle.production_year == vehicle_attrs[:production_year]
  end

  test "create_vehicle/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Cars.create_vehicle(@invalid_attrs)
  end

  @tag :skip
  test "update_vehicle/2 with valid data updates the vehicle" do
    vehicle = insert(:vehicle)
    assert {:ok, vehicle} = Cars.update_vehicle(vehicle, @update_attrs)
    assert %Vehicle{} = vehicle
    assert vehicle.model_year == "some updated model_year"
    assert vehicle.plate == "some updated plate"
    assert vehicle.production_year == "some updated production_year"
  end

  @tag :skip
  test "update_vehicle/2 with invalid data returns error changeset" do
    vehicle = insert(:vehicle)
    assert {:error, %Ecto.Changeset{}} = Cars.update_vehicle(vehicle, @invalid_attrs)
    # assert vehicle == Cars.get_vehicle!(vehicle.id)
  end

  test "delete_vehicle/1 deletes the vehicle" do
    vehicle = insert(:vehicle)
    assert {:ok, %Vehicle{}} = Cars.delete_vehicle(vehicle)
    assert_raise Ecto.NoResultsError, fn -> Cars.get_vehicle!(vehicle.id) end
  end
end
