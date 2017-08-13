defmodule EasyFixApi.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  import EasyFixApi.Helpers

  alias EasyFixApi.{Repo, Addresses, Payments}
  alias EasyFixApi.Accounts.{User, Garage}
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
    |> Repo.preload(:user)
  end

  def get_garage!(id) do
    Repo.get!(Garage, id)
    |> garage_preload_all_nested_assocs()
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

        garage =
          garage_changeset
          |> put_assoc(:user, user)
          |> put_assoc(:bank_account, bank_account)
          |> put_assoc(:garage_categories, garage_categories)
          |> Repo.insert!()

        {:ok, _address} =
          garage_assoc_attrs[:address]
          |> Addresses.create_address(garage.user.id)

        garage
        |> garage_preload_all_nested_assocs()
      end
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end

  # FIXME: ainda não funciona, mas não é prioridade
  def update_garage(%Garage{} = garage, attrs) do
    case Garage.assoc_changeset(attrs) do
      assoc_changeset = %{valid?: true} ->
        inserted_category_ids = for %{id: id} <- garage.garage_categories, do: id

        garage_assocs = apply_changes(assoc_changeset)
        garage_categories =
          garage_assocs[:garage_categories_ids]
          |> Enum.concat(inserted_category_ids)
          |> Enum.map(&Repo.get(GarageCategory, &1))

        Repo.transaction fn ->
          {:ok, user} = update_user(garage.user, attrs)

          garage
          |> Garage.changeset(attrs)
          |> put_assoc(:user, user)
          |> put_assoc(:garage_categories, garage_categories)
          |> Repo.update!()

          get_garage!(garage.id)
        end
      invalid_assoc_changeset ->
        {:error, invalid_assoc_changeset}
    end
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
end
