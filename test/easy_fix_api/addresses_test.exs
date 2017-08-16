defmodule EasyFixApi.AddressesTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Addresses
  alias EasyFixApi.Accounts

  @create_attrs %{address_line1: "some address_line1",
  address_line2: "some address_line2",
  neighborhood: "some neighborhood",
  postal_code: "some postal_code"}
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

  setup do
    {:ok, state_x = %{id: id_x}} = Addresses.create_state(%{name: "state_x"})
    {:ok, city_a} = Addresses.create_city(%{name: "city_a", state_id: id_x})
    {:ok, city_b} = Addresses.create_city(%{name: "city_b", state_id: id_x})

    {:ok, user} = Accounts.create_user(%{email: "user@email.com", password: "password"})

    [
      state_x: state_x,
      city_a: city_a,
      city_b: city_b,
      user: user,
    ]
  end

  def fixture(:address, attrs, city, user) do
    {:ok, address} =
      attrs
      |> put_in([:city], city.id)
      |> put_in([:user], user.id)
      |> Addresses.create_address()

    address
  end

  test "creates a state and a city and associates them" do
    {:ok, state = %{id: id}} = Addresses.create_state(%{name: "São Paulo"})
    attrs = %{name: "São Paulo", state_id: id}
    {:ok, city} = Addresses.create_city(attrs)

    %{cities: cities} = Repo.preload(state, :cities)
    [^city] = Repo.preload(cities, :state)
  end

  test "creates an address", %{city_a: city_a, user: user} do
    attrs =
      @create_attrs
      |> put_in([:city_id], city_a.id)

    assert {:ok, address} = Addresses.create_address(attrs, user.id)
    assert address.address_line1 == "some address_line1"
    assert address.city.id == city_a.id
    assert address.user.id == user.id
    ^city_a = Repo.preload(address.city, :state)
  end

  test "does not create address when data is invalid" do
    assert {:error, _changeset_errors} = Addresses.create_address(@invalid_attrs)
  end

  @tag :skip # FIXME: dando skip pois ainda não sei como fazer update de assocs
  test "updates an address", %{city_a: city_a, city_b: city_b, user: user} do
    address = fixture(:address, @create_attrs, city_a, user)

    attrs = %{address: @update_attrs, city: city_b.id}
    assert {:ok, address} = Addresses.update_address(address, attrs)
    assert address.address_line1 == "some updated address_line1"
    assert address.city.id == city_b.id
    assert address.user.id == user.id
  end
end
