defmodule EasyFixApi.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  import EasyFixApi.Helpers

  alias EasyFixApi.{Repo, Addresses, Payments}
  alias EasyFixApi.Accounts.{User, Garage}
  alias EasyFixApi.Cars
  alias EasyFixApi.Parts.GarageCategory

  def get_by_email("garage", email) do
    from(g in Garage,
      join: u in User,
      on: g.user_id == u.id,
      where: u.email == ^email
    )
    |> Repo.one
    |> garage_preload_all_nested_assocs()
  end

  def list_users do
    Repo.all(User)
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end
  def get_user_by_type_id("garage", garage_id) do
    from(g in Garage,
      join: u in User,
      on: g.user_id == u.id,
      where: g.id == ^garage_id,
      select: u
    )
    |> Repo.one
  end

  def get_user_by(clauses) do
    Repo.get_by(User, clauses)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def list_garages do
    Repo.all(Garage)
    |> Repo.preload(user: [], garage_categories: [])
  end

  def get_garage!(id) do
    Repo.get!(Garage, id)
    |> garage_preload_all_nested_assocs()
  end

  def get_garage_categories_ids!(id) do
    from(
      g in Garage,
      join: gcs in assoc(g, :garage_categories),
      where: ^id == g.id,
      select: gcs.id
    ) |> Repo.all
  end

  def garage_preload_all_nested_assocs(garage) do
    Repo.preload(garage, Garage.all_nested_assocs)
  end

  def create_garage(attrs \\ %{}) do
    with garage_changeset = %{valid?: true} <- Garage.create_changeset(attrs),
         garage_assoc_changeset = %{valid?: true} <- Garage.assoc_changeset(attrs),
         garage_assoc_attrs <- apply_changes_ensure_atom_keys(garage_assoc_changeset) do

      garage_categories =
        (garage_assoc_attrs[:garage_categories_ids] || [])
        |> Enum.map(&Repo.get(GarageCategory, &1))

      Repo.transaction fn ->
        {:ok, user} = create_user(attrs)

        {:ok, bank_account} =
          garage_assoc_attrs[:bank_account]
          |> Payments.create_bank_account()

        {:ok, address} =
          garage_assoc_attrs[:address]
          |> Addresses.create_address()

        garage =
          garage_changeset
          |> put_assoc(:user, user)
          |> put_assoc(:address, address)
          |> put_assoc(:bank_account, bank_account)
          |> put_assoc(:garage_categories, garage_categories)
          |> Repo.insert!()

        garage
        |> garage_preload_all_nested_assocs()
      end
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  # FIXME: ainda não está correto, mas não é prioridade
  def update_garage(%Garage{} = garage, attrs) do
    garage
    |> Garage.changeset(attrs)
    |> Repo.update!()
  end

  def delete_garage(%Garage{} = garage) do
    Repo.delete(garage)
  end

  def change_garage(%Garage{} = garage) do
    Garage.changeset(garage, %{})
  end

  def garage_preload(garage_or_garages, field) do
    Repo.preload(garage_or_garages, field)
  end

  alias EasyFixApi.Accounts.Customer

  def list_customers do
    Repo.all(Customer)
    |> Repo.preload(Customer.all_nested_assocs)
  end

  def get_customer!(id) do
    Repo.get!(Customer, id)
    |> Repo.preload(Customer.all_nested_assocs)
  end

  def create_customer(attrs \\ %{}) do
    with customer_changeset = %{valid?: true} <- Customer.create_changeset(attrs),
         customer_assoc_changeset = %{valid?: true} <- Customer.assoc_changeset(attrs),
         customer_assoc_attrs <- apply_changes_ensure_atom_keys(customer_assoc_changeset) do

      Repo.transaction fn ->
        {:ok, user} = create_user(attrs)

        {:ok, bank_account} =
          customer_assoc_attrs[:bank_account]
          |> Payments.create_bank_account()

        {:ok, address} =
          customer_assoc_attrs[:address]
          |> Addresses.create_address()

        vehicles = for vehicle_attrs <- customer_assoc_attrs[:vehicles] do
          {:ok, vehicle} = Cars.create_vehicle(vehicle_attrs)
          vehicle
        end

        customer =
          customer_changeset
          |> put_assoc(:user, user)
          |> put_assoc(:bank_account, bank_account)
          |> put_assoc(:address, address)
          |> put_assoc(:vehicles, vehicles)
          |> Repo.insert!()

        customer
        |> Repo.preload(Customer.all_nested_assocs)
      end
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end

end
