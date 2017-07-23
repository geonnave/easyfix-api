defmodule EasyFixApi.Addresses do
  @moduledoc """
  The boundary for the Addresses system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EasyFixApi.{Repo, Accounts, Helpers}

  alias EasyFixApi.Addresses.State

  def list_states do
    Repo.all(State)
  end

  def get_state!(id), do: Repo.get!(State, id)

  def create_state(attrs \\ %{}) do
    %State{}
    |> State.changeset(attrs)
    |> Repo.insert()
  end

  def update_state(%State{} = state, attrs) do
    state
    |> State.changeset(attrs)
    |> Repo.update()
  end

  def delete_state(%State{} = state) do
    Repo.delete(state)
  end

  def change_state(%State{} = state) do
    State.changeset(state, %{})
  end

  alias EasyFixApi.Addresses.City

  def list_cities do
    Repo.all(City)
    |> Repo.preload([:state])
  end

  def get_city!(id), do: Repo.get!(City, id)

  def create_city(attrs \\ %{}) do
    state = get_state!(attrs[:state_id])

    %City{}
    |> City.changeset(attrs)
    |> put_assoc(:state, state)
    |> Repo.insert()
  end

  def update_city(%City{} = city, attrs) do
    city
    |> City.changeset(attrs)
    |> Repo.update()
  end

  def delete_city(%City{} = city) do
    Repo.delete(city)
  end

  def change_city(%City{} = city) do
    City.changeset(city, %{})
  end

  alias EasyFixApi.Addresses.Address

  defp preload_all_nested_associations(address) do
    Repo.preload(address, [city: [:state]])
  end

  def list_addresses do
    Repo.all(Address)
    |> preload_all_nested_associations()
  end

  def get_address!(id) do
    Repo.get!(Address, id)
    |> preload_all_nested_associations()
  end

  def create_address(attrs \\ %{}, user_id) do
    with address_changeset = %{valid?: true} <- Address.create_changeset(attrs),
         address_assoc_changeset = %{valid?: true} <- Address.assoc_changeset(attrs),
         address_assoc_attrs <- Helpers.apply_changes_ensure_atom_keys(address_assoc_changeset) do

      city = get_city!(address_assoc_attrs[:city_id])
      user = Accounts.get_user!(user_id)

      address_changeset
      |> put_assoc(:city, city)
      |> put_assoc(:user, user)
      |> Repo.insert()
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  # FIXME: ainda não funciona
  #  dúvida: aprender como fazer update de assocs
  def update_address(%Address{} = address, attrs) do
    address
    |> Address.changeset(attrs)
    |> Repo.update()
  end

  def delete_address(%Address{} = address) do
    Repo.delete(address)
  end

  def change_address(%Address{} = address) do
    Address.changeset(address, %{})
  end
end
