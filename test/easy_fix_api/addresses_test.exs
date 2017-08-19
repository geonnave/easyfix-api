defmodule EasyFixApi.AddressesTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Addresses

  @update_attrs %{address_line1: "some updated address_line1",
  address_line2: "some updated address_line2",
  neighborhood: "some updated neighborhood",
  postal_code: "some updated postal_code"}
  @invalid_attrs %{address_line1: nil,
  address_line2: nil,
  neighborhood: nil,
  city: nil,
  user: nil,
  postal_code: nil}

  test "creates a state and a city and associates them" do
    {:ok, state = %{id: id}} = Addresses.create_state(%{name: "São Paulo"})
    attrs = %{name: "São Paulo", state_id: id}
    {:ok, city} = Addresses.create_city(attrs)

    %{cities: cities} = Repo.preload(state, :cities)
    [^city] = Repo.preload(cities, :state)
  end

  test "creates an address" do
    city = insert(:city)
    address_attrs =
      params_for(:address)
      |> put_in([:city_id], city.id)

    assert {:ok, address} = Addresses.create_address(address_attrs)
    assert address.address_line1 == address_attrs[:address_line1]
    assert address.city.id == city.id
    ^city = Repo.preload(address.city, :state)
  end

  test "does not create address when data is invalid" do
    assert {:error, _changeset_errors} = Addresses.create_address(@invalid_attrs)
  end

  @tag :skip # TODO
  test "updates an address" do
    address = insert(:address)
    new_city = insert(:city)

    attrs = %{address: @update_attrs, city: new_city.id}
    assert {:ok, address} = Addresses.update_address(address, attrs)
    assert address.address_line1 == "some updated address_line1"
    assert address.city.id == new_city.id
  end
end
