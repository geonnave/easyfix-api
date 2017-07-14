defmodule EasyFixApi.AddressesTest do
  use EasyFixApi.DataCase

  alias EasyFixApi.Addresses
  alias EasyFixApi.Addresses.State

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:state, attrs \\ @create_attrs) do
    {:ok, state} = Addresses.create_state(attrs)
    state
  end

  test "list_states/1 returns all states" do
    state = fixture(:state)
    assert Addresses.list_states() == [state]
  end

  test "get_state! returns the state with given id" do
    state = fixture(:state)
    assert Addresses.get_state!(state.id) == state
  end

  test "create_state/1 with valid data creates a state" do
    assert {:ok, %State{} = state} = Addresses.create_state(@create_attrs)
    assert state.name == "some name"
  end

  test "create_state/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Addresses.create_state(@invalid_attrs)
  end

  test "update_state/2 with valid data updates the state" do
    state = fixture(:state)
    assert {:ok, state} = Addresses.update_state(state, @update_attrs)
    assert %State{} = state
    assert state.name == "some updated name"
  end

  test "update_state/2 with invalid data returns error changeset" do
    state = fixture(:state)
    assert {:error, %Ecto.Changeset{}} = Addresses.update_state(state, @invalid_attrs)
    assert state == Addresses.get_state!(state.id)
  end

  test "delete_state/1 deletes the state" do
    state = fixture(:state)
    assert {:ok, %State{}} = Addresses.delete_state(state)
    assert_raise Ecto.NoResultsError, fn -> Addresses.get_state!(state.id) end
  end

  test "change_state/1 returns a state changeset" do
    state = fixture(:state)
    assert %Ecto.Changeset{} = Addresses.change_state(state)
  end
end
